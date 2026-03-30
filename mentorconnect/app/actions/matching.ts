"use server";

import { createClient } from "@/lib/supabase/server";
import { generateMatchMatches, MenteeProfile, MentorProfile } from "@/lib/matchingEngine";

type LanguageJoin = { code?: string } | Array<{ code?: string }> | null;
type UserLanguageRow = { user_id?: string; languages?: LanguageJoin };
type UserTagRow = { user_id?: string; tag_id?: number };
type ActiveMembershipRow = { id: string; group_id: string };
type MentorGroupBasicRow = {
  id: string;
  mentor_id: string;
  max_capacity: number;
  current_count: number;
  is_active: boolean;
};
type MentorGeneralProfileRow = {
  user_id: string;
  department: string | null;
  full_name: string | null;
  college_email: string | null;
};
type MenteeProfileRow = {
  user_id: string;
  academic_background: string;
  preferred_mentor_background: string | null;
  preferred_mentor_domain: string[] | null;
};
type UserDepartmentRow = {
  user_id: string;
  department: string | null;
};
type UserRoleRow = {
  user_id: string;
  role_id: number;
};

const HIGHEST_ADMIN_ROLE_ID = 7;
type SupabaseServerClient = Awaited<ReturnType<typeof createClient>>;

async function assertHighestRoleAdmin(supabase: SupabaseServerClient, userId: string) {
  const { data: highestRole, error: roleError } = await supabase
    .from("user_roles")
    .select("role_id")
    .eq("user_id", userId)
    .eq("role_id", HIGHEST_ADMIN_ROLE_ID)
    .eq("is_active", true)
    .maybeSingle();

  if (roleError) {
    throw new Error("Unable to verify admin role: " + roleError.message);
  }

  if (!highestRole) {
    throw new Error("Only highest-role admins can perform this action.");
  }
}

async function getHighestRoleByUserIds(supabase: SupabaseServerClient, userIds: string[]) {
  if (userIds.length === 0) {
    return new Map<string, number>();
  }

  const { data: roleRows, error: roleError } = await supabase
    .from("user_roles")
    .select("user_id, role_id")
    .in("user_id", userIds)
    .eq("is_active", true);

  if (roleError) {
    throw new Error("Failed to load user roles: " + roleError.message);
  }

  const highestRoleByUserId = new Map<string, number>();
  for (const roleRow of (roleRows || []) as UserRoleRow[]) {
    const current = highestRoleByUserId.get(roleRow.user_id) ?? 0;
    if (roleRow.role_id > current) {
      highestRoleByUserId.set(roleRow.user_id, roleRow.role_id);
    }
  }

  return highestRoleByUserId;
}

function getLanguagesByUserId(rows: UserLanguageRow[]) {
  const result = new Map<string, string[]>();

  for (const row of rows) {
    if (!row.user_id) continue;
    const existing = result.get(row.user_id) ?? [];

    if (Array.isArray(row.languages) && row.languages[0]?.code) {
      existing.push(row.languages[0].code);
    } else if (!Array.isArray(row.languages) && row.languages?.code) {
      existing.push(row.languages.code);
    }

    result.set(row.user_id, existing);
  }

  return result;
}

function getInterestsByUserId(rows: UserTagRow[]) {
  const result = new Map<string, number[]>();

  for (const row of rows) {
    if (!row.user_id || typeof row.tag_id !== "number") continue;
    const existing = result.get(row.user_id) ?? [];
    existing.push(row.tag_id);
    result.set(row.user_id, existing);
  }

  return result;
}

type BestMentorSuggestion = {
  menteeId: string;
  mentorId: string;
  matchScore: number;
  mentorName: string;
  mentorEmail: string | null;
  mentorDepartment: string | null;
};

async function computeBestMentorSuggestions(supabase: SupabaseServerClient, menteeIds: string[]) {
  if (menteeIds.length === 0) {
    return [] as BestMentorSuggestion[];
  }

  const { data: menteeRowsData, error: menteeRowsError } = await supabase
    .from("mentee_profiles")
    .select("user_id, academic_background, preferred_mentor_background, preferred_mentor_domain")
    .in("user_id", menteeIds);

  if (menteeRowsError) {
    throw new Error("Failed to load mentee profiles: " + menteeRowsError.message);
  }

  const { data: mentorRowsData, error: mentorRowsError } = await supabase
    .from("mentor_ug_pg_profiles")
    .select("user_id, academic_background, mentoring_domains, max_mentees, current_mentees_count, is_accepting_mentees")
    .eq("is_accepting_mentees", true);

  if (mentorRowsError) {
    throw new Error("Failed to load mentor profiles: " + mentorRowsError.message);
  }

  const mentorRows = mentorRowsData || [];
  const mentorIds = mentorRows.map((row) => row.user_id as string);

  if (mentorIds.length === 0) {
    return [] as BestMentorSuggestion[];
  }

  const allRoleIdsToResolve = Array.from(new Set([...menteeIds, ...mentorIds]));
  const highestRoleByUserId = await getHighestRoleByUserIds(supabase, allRoleIdsToResolve);

  const [{ data: menteeDepartmentsData }, { data: mentorGeneralProfilesData }, { data: languageRowsData }, { data: interestRowsData }] =
    await Promise.all([
      supabase.from("user_profiles").select("user_id, department").in("user_id", menteeIds),
      supabase.from("user_profiles").select("user_id, full_name, college_email, department").in("user_id", mentorIds),
      supabase.from("user_languages").select("user_id, languages(code)").in("user_id", allRoleIdsToResolve),
      supabase.from("user_interests").select("user_id, tag_id").in("user_id", allRoleIdsToResolve),
    ]);

  const menteeById = new Map<string, MenteeProfileRow>(
    ((menteeRowsData || []) as MenteeProfileRow[]).map((row) => [row.user_id, row]),
  );

  const menteeDepartmentById = new Map<string, string | null>(
    ((menteeDepartmentsData || []) as UserDepartmentRow[]).map((row) => [row.user_id, row.department]),
  );

  const mentorGeneralById = new Map<string, MentorGeneralProfileRow>(
    ((mentorGeneralProfilesData || []) as MentorGeneralProfileRow[]).map((row) => [row.user_id, row]),
  );

  const languageByUserId = getLanguagesByUserId((languageRowsData || []) as UserLanguageRow[]);
  const interestsByUserId = getInterestsByUserId((interestRowsData || []) as UserTagRow[]);

  const mentors: MentorProfile[] = mentorRows
    .map((row) => {
      const mentorId = row.user_id as string;
      const mentorRole = highestRoleByUserId.get(mentorId) ?? 0;

      if (mentorRole === HIGHEST_ADMIN_ROLE_ID) {
        return null;
      }

      return {
        id: mentorId,
        academic_background: row.academic_background,
        mentoring_domains: row.mentoring_domains || [],
        max_mentees: row.max_mentees,
        current_mentees_count: row.current_mentees_count,
        is_accepting_mentees: row.is_accepting_mentees,
        department: mentorGeneralById.get(mentorId)?.department || null,
        languages: languageByUserId.get(mentorId) || [],
        interests: interestsByUserId.get(mentorId) || [],
      };
    })
    .filter((mentor): mentor is MentorProfile => Boolean(mentor));

  const suggestions: BestMentorSuggestion[] = [];

  for (const menteeId of menteeIds) {
    const menteeData = menteeById.get(menteeId);
    if (!menteeData) continue;

    const menteeRole = highestRoleByUserId.get(menteeId) ?? 1;

    const mentee: MenteeProfile = {
      id: menteeId,
      academic_background: menteeData.academic_background,
      preferred_mentor_background: menteeData.preferred_mentor_background,
      preferred_mentor_domain: menteeData.preferred_mentor_domain || [],
      department: menteeDepartmentById.get(menteeId) || null,
      languages: languageByUserId.get(menteeId) || [],
      interests: interestsByUserId.get(menteeId) || [],
    };

    const eligibleMentors = mentors.filter((mentor) => {
      const mentorRole = highestRoleByUserId.get(mentor.id) ?? 0;
      return mentorRole > menteeRole && mentorRole !== HIGHEST_ADMIN_ROLE_ID;
    });

    const best = generateMatchMatches(mentee, eligibleMentors)[0];
    if (!best) continue;

    const bestMentorGeneral = mentorGeneralById.get(best.mentorId);

    suggestions.push({
      menteeId,
      mentorId: best.mentorId,
      matchScore: best.matchScore,
      mentorName: bestMentorGeneral?.full_name || "Unknown mentor",
      mentorEmail: bestMentorGeneral?.college_email || null,
      mentorDepartment: bestMentorGeneral?.department || null,
    });
  }

  return suggestions;
}

async function refreshGroupCurrentCount(supabase: SupabaseServerClient, groupId: string) {
  const { count: activeCount, error: activeCountError } = await supabase
    .from("mentor_group_members")
    .select("*", { count: "exact", head: true })
    .eq("group_id", groupId)
    .eq("status", "active");

  if (activeCountError) {
    throw new Error("Failed to recalculate group count: " + activeCountError.message);
  }

  const refreshedCount = activeCount ?? 0;

  const { error: updateGroupCountError } = await supabase
    .from("mentor_groups")
    .update({ current_count: refreshedCount })
    .eq("id", groupId);

  if (updateGroupCountError) {
    throw new Error("Failed to update mentor group count: " + updateGroupCountError.message);
  }

  return refreshedCount;
}

async function refreshMentorMenteeCount(supabase: SupabaseServerClient, mentorId: string) {
  const { data: mentorGroups, error: mentorGroupsError } = await supabase
    .from("mentor_groups")
    .select("id")
    .eq("mentor_id", mentorId)
    .eq("is_active", true);

  if (mentorGroupsError) {
    throw new Error("Failed to refresh mentor count: " + mentorGroupsError.message);
  }

  const mentorGroupIds = (mentorGroups || []).map((group) => group.id as string);
  let activeMenteeCount = 0;

  if (mentorGroupIds.length > 0) {
    const { count, error: membershipCountError } = await supabase
      .from("mentor_group_members")
      .select("*", { count: "exact", head: true })
      .in("group_id", mentorGroupIds)
      .eq("status", "active");

    if (membershipCountError) {
      throw new Error("Failed to refresh mentor count: " + membershipCountError.message);
    }

    activeMenteeCount = count ?? 0;
  }

  const { error: updateMentorCountError } = await supabase
    .from("mentor_ug_pg_profiles")
    .update({ current_mentees_count: activeMenteeCount })
    .eq("user_id", mentorId);

  if (updateMentorCountError) {
    throw new Error("Failed to update mentor mentee count: " + updateMentorCountError.message);
  }

  return activeMenteeCount;
}

async function allocateMenteeToMentor(
  supabase: SupabaseServerClient,
  targetMenteeId: string,
  mentorId: string,
  actorUserId: string,
) {
  const roleMap = await getHighestRoleByUserIds(supabase, [targetMenteeId, mentorId]);
  const menteeRole = roleMap.get(targetMenteeId) ?? 1;
  const mentorRole = roleMap.get(mentorId) ?? 0;

  if (!mentorRole) {
    throw new Error("Selected mentor does not have an active role.");
  }

  if (mentorRole === HIGHEST_ADMIN_ROLE_ID) {
    throw new Error("Admin role cannot be assigned as mentor.");
  }

  if (mentorRole <= menteeRole) {
    throw new Error("Mentor must have a higher role than the mentee.");
  }

  const { data: mentorProfileRow, error: mentorProfileError } = await supabase
    .from("mentor_ug_pg_profiles")
    .select("user_id")
    .eq("user_id", mentorId)
    .maybeSingle();

  if (mentorProfileError) {
    throw new Error("Failed to validate mentor profile: " + mentorProfileError.message);
  }

  if (!mentorProfileRow) {
    throw new Error("Selected user is not an active mentor.");
  }

  const { data: activeMembershipsData, error: activeMembershipsError } = await supabase
    .from("mentor_group_members")
    .select("id, group_id")
    .eq("mentee_id", targetMenteeId)
    .eq("status", "active");

  if (activeMembershipsError) {
    throw new Error("Failed to load existing group memberships: " + activeMembershipsError.message);
  }

  const activeMemberships = (activeMembershipsData || []) as ActiveMembershipRow[];
  const activeGroupIds = activeMemberships.map((membership) => membership.group_id);

  let alreadyAssignedMembershipId: string | null = null;
  let membershipIdsToTransfer: string[] = [];
  const mentorsToRefresh = new Set<string>();

  if (activeGroupIds.length > 0) {
    const { data: activeGroupsData, error: activeGroupsError } = await supabase
      .from("mentor_groups")
      .select("id, mentor_id")
      .in("id", activeGroupIds);

    if (activeGroupsError) {
      throw new Error("Failed to resolve active mentor groups: " + activeGroupsError.message);
    }

    const activeGroupsById = new Map(
      ((activeGroupsData || []) as Array<{ id: string; mentor_id: string }>).map((group) => [
        group.id,
        group,
      ]),
    );

    for (const membership of activeMemberships) {
      const group = activeGroupsById.get(membership.group_id);
      if (!group) continue;

      if (group.mentor_id === mentorId) {
        alreadyAssignedMembershipId = membership.id;
      } else {
        membershipIdsToTransfer.push(membership.id);
        mentorsToRefresh.add(group.mentor_id);
      }
    }
  }

  if (alreadyAssignedMembershipId) {
    return {
      success: true,
      alreadyAssigned: true,
      mentorId,
      message: "Mentee is already assigned to this mentor.",
    };
  }

  if (membershipIdsToTransfer.length > 0) {
    const { error: transferError } = await supabase
      .from("mentor_group_members")
      .update({
        status: "transferred",
        left_at: new Date().toISOString(),
      })
      .in("id", membershipIdsToTransfer)
      .eq("status", "active");

    if (transferError) {
      throw new Error("Failed to transfer previous mentor assignments: " + transferError.message);
    }
  }

  let targetGroup: MentorGroupBasicRow | null = null;

  const { data: mentorGroupsData, error: mentorGroupsError } = await supabase
    .from("mentor_groups")
    .select("id, mentor_id, max_capacity, current_count, is_active")
    .eq("mentor_id", mentorId)
    .eq("is_active", true)
    .order("current_count", { ascending: true })
    .limit(1);

  if (mentorGroupsError) {
    throw new Error("Failed to fetch mentor groups: " + mentorGroupsError.message);
  }

  const firstExistingGroup = ((mentorGroupsData || []) as MentorGroupBasicRow[])[0] ?? null;
  if (firstExistingGroup && firstExistingGroup.current_count < firstExistingGroup.max_capacity) {
    targetGroup = firstExistingGroup;
  }

  if (!targetGroup) {
    const { data: createdGroup, error: createGroupError } = await supabase
      .from("mentor_groups")
      .insert({
        mentor_id: mentorId,
        group_name: `Mentor Group ${mentorId.slice(0, 8)}`,
        max_capacity: 5,
        current_count: 0,
        is_active: true,
        created_by: actorUserId,
      })
      .select("id, mentor_id, max_capacity, current_count, is_active")
      .single();

    if (createGroupError || !createdGroup) {
      throw new Error("Failed to create mentor group: " + createGroupError?.message);
    }

    targetGroup = createdGroup as MentorGroupBasicRow;
  }

  const { error: assignError } = await supabase
    .from("mentor_group_members")
    .upsert(
      {
        group_id: targetGroup.id,
        mentee_id: targetMenteeId,
        added_by: actorUserId,
        status: "active",
        match_status: "assigned",
        left_at: null,
      },
      { onConflict: "group_id,mentee_id" },
    );

  if (assignError) {
    throw new Error("Failed to assign mentor: " + assignError.message);
  }

  const refreshedCount = await refreshGroupCurrentCount(supabase, targetGroup.id);
  await refreshMentorMenteeCount(supabase, mentorId);

  for (const previousMentorId of mentorsToRefresh) {
    await refreshMentorMenteeCount(supabase, previousMentorId);
  }

  const { data: mentorProfile } = await supabase
    .from("user_profiles")
    .select("full_name, college_email, department")
    .eq("user_id", mentorId)
    .maybeSingle();

  return {
    success: true,
    alreadyAssigned: false,
    mentorId,
    menteeId: targetMenteeId,
    groupId: targetGroup.id,
    activeMenteeCount: refreshedCount,
    mentorName: mentorProfile?.full_name || "Unknown mentor",
    mentorEmail: mentorProfile?.college_email || null,
    mentorDepartment: mentorProfile?.department || null,
    message: "Mentor allocated successfully.",
  };
}

export async function runMatchingAlgorithm() {
  const supabase = await createClient();
  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser();

  if (authError || !user) {
    throw new Error("You must be logged in to run matching.");
  }

  // Always use the authenticated user's id to avoid mismatches with legacy/custom user rows.
  const targetMenteeId = user.id;

  // 1. Fetch Mentee Profile details
  let { data: menteeRows, error: menteeError } = await supabase
    .from("mentee_profiles")
    .select(`
      user_id,
      academic_background,
      preferred_mentor_background,
      preferred_mentor_domain
    `)
    .eq("user_id", targetMenteeId)
    .limit(1);

  let menteeData = menteeRows?.[0] ?? null;

  // Self-heal: if a mentee profile row is missing, try to bootstrap one from onboarding context.
  if (!menteeError && !menteeData) {
    const { error: bootstrapMenteeError } = await supabase
      .from("mentee_profiles")
      .upsert(
        {
          user_id: targetMenteeId,
          academic_background: "Other",
          current_challenges: [],
          preferred_mentor_background: null,
          preferred_mentor_domain: [],
          communication_preference: "both",
        },
        { onConflict: "user_id" },
      );

    if (!bootstrapMenteeError) {
      const { data: retryRows, error: retryError } = await supabase
        .from("mentee_profiles")
        .select(`
          user_id,
          academic_background,
          preferred_mentor_background,
          preferred_mentor_domain
        `)
        .eq("user_id", targetMenteeId)
        .limit(1);

      menteeRows = retryRows;
      menteeError = retryError;
      menteeData = retryRows?.[0] ?? null;
    } else {
      menteeError = bootstrapMenteeError;
    }
  }

  if (menteeError || !menteeData) {
    const { data: activeMenteeRole } = await supabase
      .from("user_roles")
      .select("role_id")
      .eq("user_id", targetMenteeId)
      .eq("role_id", 1)
      .eq("is_active", true)
      .maybeSingle();

    throw new Error(
      menteeError?.message
        ? "Failed to fetch mentee profile: " + menteeError.message
        : activeMenteeRole
          ? "No mentee profile found for this user. Please reopen Profile and save once to complete mentee setup."
          : "Your account does not have an active mentee role yet. Complete mentee onboarding first."
    );
  }

  // Fetch mentee's general profile (for department)
  const { data: menteeProfileRows, error: menteeProfileError } = await supabase
    .from("user_profiles")
    .select("department")
    .eq("user_id", targetMenteeId)
    .limit(1);

  if (menteeProfileError) {
    throw new Error("Failed to fetch user profile: " + menteeProfileError.message);
  }

  const menteeProfileData = menteeProfileRows?.[0] ?? null;

  // 2. Fetch Mentee Attributes (Languages & Interests)
  const [{ data: menteeLangs }, { data: menteeTags }] = await Promise.all([
    supabase.from("user_languages").select("languages(code)").eq("user_id", targetMenteeId),
    supabase.from("user_interests").select("tag_id").eq("user_id", targetMenteeId)
  ]);

  const menteeLanguages = (menteeLangs || [])
    .map((entry) => {
      const row = entry as UserLanguageRow;
      if (!row.languages) return null;
      if (Array.isArray(row.languages)) {
        return row.languages[0]?.code ?? null;
      }
      return row.languages.code ?? null;
    })
    .filter((language): language is string => Boolean(language));
  const menteeInterests = (menteeTags || []).map((t) => t.tag_id as number);

  // Reconstruct Mentee
  const mentee: MenteeProfile = {
    id: menteeData.user_id,
    academic_background: menteeData.academic_background,
    preferred_mentor_background: menteeData.preferred_mentor_background,
    preferred_mentor_domain: menteeData.preferred_mentor_domain || [],
    department: menteeProfileData?.department || null,
    languages: menteeLanguages,
    interests: menteeInterests,
  };

  // 3. Fetch Mentor Profiles
  // For v1, let's fetch UG/PG mentors who are accepting mentees
  const { data: mentorsData, error: mentorsError } = await supabase
    .from("mentor_ug_pg_profiles")
    .select(`
      user_id,
      academic_background,
      mentoring_domains,
      max_mentees,
      current_mentees_count,
      is_accepting_mentees
    `)
    .eq("is_accepting_mentees", true);

  if (mentorsError || !mentorsData) {
    throw new Error("Failed to fetch mentors: " + mentorsError?.message);
  }

  // 4. Extract all Mentors Attributes (We'll do an `in` query for efficiency)
  const mentorIds = mentorsData.map(m => m.user_id);
  const [{ data: mentorLangs }, { data: mentorTags }, { data: mentorGeneralProfiles }] = await Promise.all([
    supabase.from("user_languages").select("user_id, languages(code)").in("user_id", mentorIds),
    supabase.from("user_interests").select("user_id, tag_id").in("user_id", mentorIds),
    supabase
      .from("user_profiles")
      .select("user_id, department, full_name, college_email")
      .in("user_id", mentorIds)
  ]);

  // Create a map of mentor general profiles for quick access
  const mentorGeneralProfileMap = new Map(
    ((mentorGeneralProfiles || []) as MentorGeneralProfileRow[]).map((p) => [p.user_id, p]),
  );

  // Map them properly
  const mentorsMap = new Map<string, MentorProfile>();
  for (const row of mentorsData) {
    mentorsMap.set(row.user_id, {
      id: row.user_id,
      academic_background: row.academic_background,
      mentoring_domains: row.mentoring_domains || [],
      max_mentees: row.max_mentees,
      current_mentees_count: row.current_mentees_count,
      is_accepting_mentees: row.is_accepting_mentees,
      department: mentorGeneralProfileMap.get(row.user_id)?.department || null,
      languages: [],
      interests: []
    });
  }

  // Populate Languages
  for (const item of (mentorLangs || [])) {
    const lang = item as UserLanguageRow;
    if (!lang.user_id) continue;
    const prof = mentorsMap.get(lang.user_id);
    if (prof && lang.languages?.code) {
        prof.languages.push(lang.languages.code);
    } else if (prof && Array.isArray(lang.languages) && lang.languages[0]?.code) {
        prof.languages.push(lang.languages[0].code);
    }
  }

  // Populate Tags
  for (const item of (mentorTags || [])) {
    const tag = item as UserTagRow;
    if (!tag.user_id || typeof tag.tag_id !== "number") continue;
    const prof = mentorsMap.get(tag.user_id);
    if (prof) {
        prof.interests.push(tag.tag_id);
    }
  }

  // Convert map to array
  const mentors = Array.from(mentorsMap.values());

  // 5. Generate Match Scores
  const results = generateMatchMatches(mentee, mentors);

  // 6. Limit to top 5 and store in ml_match_predictions
  const topResults = results.slice(0, 5);

  if (topResults.length === 0) {
    return { success: true, count: 0, message: "No mentors found meeting the criteria." };
  }

  const inserts = topResults.map(r => ({
      mentee_id: r.menteeId,
      mentor_id: r.mentorId,
      match_score: r.matchScore,
      score_breakdown: r.scoreBreakdown,
      model_version: "v1-demographic-heuristic"
  }));

  // Upsert the results to handle unique constraint (mentee_id, mentor_id, model_version)
  const { error: insertError } = await supabase
      .from("ml_match_predictions")
      .upsert(inserts, { onConflict: 'mentee_id, mentor_id, model_version' });

  if (insertError) {
    console.error("Failed to insert predictions", insertError);
    throw new Error("Failed to store match predictions: " + insertError.message);
  }

  const enrichedResults = topResults.map((result) => {
    const mentorProfile = mentorGeneralProfileMap.get(result.mentorId);
    return {
      ...result,
      mentorName: mentorProfile?.full_name || "Unknown mentor",
      mentorEmail: mentorProfile?.college_email || null,
      mentorDepartment: mentorProfile?.department || null,
    };
  });

  const allocatedMentor = enrichedResults[0] ?? null;

  return {
    success: true,
    count: enrichedResults.length,
    allocatedMentor,
    data: enrichedResults,
  };
}

export async function confirmMentorAllocation(mentorId: string) {
  const supabase = await createClient();
  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser();

  if (authError || !user) {
    throw new Error("You must be logged in to confirm mentor allocation.");
  }

  if (!mentorId) {
    throw new Error("Mentor id is required for allocation.");
  }

  const targetMenteeId = user.id;
  return allocateMenteeToMentor(supabase, targetMenteeId, mentorId, targetMenteeId);
}

export async function adminAllocateMentorToMentee(menteeId: string, mentorId: string) {
  const supabase = await createClient();
  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser();

  if (authError || !user) {
    throw new Error("You must be logged in to allocate mentors.");
  }

  await assertHighestRoleAdmin(supabase, user.id);

  if (!menteeId || !mentorId) {
    throw new Error("Mentee id and mentor id are required.");
  }

  return allocateMenteeToMentor(supabase, menteeId, mentorId, user.id);
}

export async function adminDeallocateMentee(menteeId: string) {
  const supabase = await createClient();
  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser();

  if (authError || !user) {
    throw new Error("You must be logged in to deallocate mentors.");
  }

  await assertHighestRoleAdmin(supabase, user.id);

  if (!menteeId) {
    throw new Error("Mentee id is required.");
  }

  const { data: activeMembershipsData, error: activeMembershipsError } = await supabase
    .from("mentor_group_members")
    .select("id, group_id")
    .eq("mentee_id", menteeId)
    .eq("status", "active");

  if (activeMembershipsError) {
    throw new Error("Failed to load active mentor assignments: " + activeMembershipsError.message);
  }

  const activeMemberships = (activeMembershipsData || []) as ActiveMembershipRow[];
  if (activeMemberships.length === 0) {
    return {
      success: true,
      menteeId,
      deallocatedCount: 0,
      message: "No active mentor assignment found for this mentee.",
    };
  }

  const groupIds = activeMemberships.map((membership) => membership.group_id);

  const { data: groupsData, error: groupsError } = await supabase
    .from("mentor_groups")
    .select("id, mentor_id")
    .in("id", groupIds);

  if (groupsError) {
    throw new Error("Failed to load mentor groups: " + groupsError.message);
  }

  const mentorIds = Array.from(
    new Set(((groupsData || []) as Array<{ id: string; mentor_id: string }>).map((group) => group.mentor_id)),
  );

  const { error: updateMembershipError } = await supabase
    .from("mentor_group_members")
    .update({
      status: "removed",
      match_status: "removed",
      left_at: new Date().toISOString(),
    })
    .in(
      "id",
      activeMemberships.map((membership) => membership.id),
    )
    .eq("status", "active");

  if (updateMembershipError) {
    throw new Error("Failed to deallocate mentor: " + updateMembershipError.message);
  }

  for (const groupId of groupIds) {
    await refreshGroupCurrentCount(supabase, groupId);
  }

  for (const mentorId of mentorIds) {
    await refreshMentorMenteeCount(supabase, mentorId);
  }

  return {
    success: true,
    menteeId,
    deallocatedCount: activeMemberships.length,
    message: "Mentor deallocated successfully.",
  };
}

export async function adminGetBestMentorSuggestions(menteeIds: string[]) {
  const supabase = await createClient();
  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser();

  if (authError || !user) {
    throw new Error("You must be logged in to generate suggestions.");
  }

  await assertHighestRoleAdmin(supabase, user.id);

  const sanitizedMenteeIds = Array.from(new Set((menteeIds || []).filter(Boolean)));
  const suggestions = await computeBestMentorSuggestions(supabase, sanitizedMenteeIds);

  return {
    success: true,
    count: suggestions.length,
    data: suggestions,
  };
}

export async function adminAllocateAllSuggestedMentors(menteeIds: string[]) {
  const supabase = await createClient();
  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser();

  if (authError || !user) {
    throw new Error("You must be logged in to allocate mentors.");
  }

  await assertHighestRoleAdmin(supabase, user.id);

  const sanitizedMenteeIds = Array.from(new Set((menteeIds || []).filter(Boolean)));
  const suggestions = await computeBestMentorSuggestions(supabase, sanitizedMenteeIds);
  const suggestionByMentee = new Map(suggestions.map((item) => [item.menteeId, item]));

  const allocated: Array<{ menteeId: string; mentorId: string; matchScore: number }> = [];
  const skipped: Array<{ menteeId: string; reason: string }> = [];

  for (const menteeId of sanitizedMenteeIds) {
    const suggestion = suggestionByMentee.get(menteeId);

    if (!suggestion) {
      skipped.push({ menteeId, reason: "No eligible mentor suggestion found." });
      continue;
    }

    try {
      await allocateMenteeToMentor(supabase, menteeId, suggestion.mentorId, user.id);
      allocated.push({
        menteeId,
        mentorId: suggestion.mentorId,
        matchScore: suggestion.matchScore,
      });
    } catch (error) {
      skipped.push({
        menteeId,
        reason: error instanceof Error ? error.message : "Allocation failed.",
      });
    }
  }

  return {
    success: true,
    allocatedCount: allocated.length,
    skippedCount: skipped.length,
    allocated,
    skipped,
    message: `Allocated ${allocated.length} mentee(s) using suggested mentors.`,
  };
}
