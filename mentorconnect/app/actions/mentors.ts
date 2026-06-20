"use server";

import { createClient } from "@/lib/supabase/server";

export interface MentorCardData {
  id: string;
  name: string;
  email: string | null;
  department: string | null;
  designation: string | null;
  bio: string | null;
  mentoringDomains: string[];
  isAcceptingMentees: boolean;
  maxMentees: number;
  currentMenteesCount: number;
  // Stats from mentor_stats table
  issuesResolved: number;
  avgRating: number | null;
  totalRatingsCount: number;
  activeMentees: number;
  totalMenteesServed: number;
}

export async function fetchAllMentors(): Promise<MentorCardData[]> {
  const supabase = await createClient();

  // 1. Fetch all mentor profiles (UG/PG mentors)
  const { data: mentorProfiles, error: mentorError } = await supabase
    .from("mentor_ug_pg_profiles")
    .select("user_id, mentoring_domains, max_mentees, current_mentees_count, is_accepting_mentees");

  if (mentorError || !mentorProfiles) {
    console.error("Failed to fetch mentor profiles:", mentorError);
    return [];
  }

  const mentorIds = mentorProfiles.map((m) => m.user_id as string);

  if (mentorIds.length === 0) return [];

  // 2. Fetch user profiles for all mentors
  const { data: userProfiles } = await supabase
    .from("user_profiles")
    .select("user_id, full_name, college_email, department, year_or_designation, short_bio")
    .in("user_id", mentorIds);

  // 3. Fetch mentor stats
  const { data: mentorStats } = await supabase
    .from("mentor_stats")
    .select("mentor_id, issues_resolved, avg_rating, total_ratings_count, active_mentees, total_mentees_served")
    .in("mentor_id", mentorIds);

  // 4. Filter out admin-role users (role_id = 7) — admins should not appear as mentors
  const { data: adminRoles } = await supabase
    .from("user_roles")
    .select("user_id")
    .eq("role_id", 7)
    .eq("is_active", true)
    .in("user_id", mentorIds);

  const adminIds = new Set((adminRoles || []).map((r) => r.user_id as string));

  // Build lookup maps
  const profileMap = new Map(
    (userProfiles || []).map((p) => [p.user_id, p])
  );
  const statsMap = new Map(
    (mentorStats || []).map((s) => [s.mentor_id, s])
  );

  // 5. Assemble final mentor cards
  const mentors: MentorCardData[] = mentorProfiles
    .filter((m) => !adminIds.has(m.user_id as string))
    .map((m) => {
      const profile = profileMap.get(m.user_id);
      const stats = statsMap.get(m.user_id);

      return {
        id: m.user_id as string,
        name: profile?.full_name || "Unknown Mentor",
        email: profile?.college_email || null,
        department: profile?.department || null,
        designation: profile?.year_or_designation || null,
        bio: profile?.short_bio || null,
        mentoringDomains: (m.mentoring_domains as string[]) || [],
        isAcceptingMentees: m.is_accepting_mentees ?? false,
        maxMentees: m.max_mentees ?? 5,
        currentMenteesCount: m.current_mentees_count ?? 0,
        issuesResolved: stats?.issues_resolved ?? 0,
        avgRating: stats?.avg_rating ? Number(stats.avg_rating) : null,
        totalRatingsCount: stats?.total_ratings_count ?? 0,
        activeMentees: stats?.active_mentees ?? 0,
        totalMenteesServed: stats?.total_mentees_served ?? 0,
      };
    })
    .sort((a, b) => a.name.localeCompare(b.name));

  return mentors;
}
