"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import {
  adminAllocateAllSuggestedMentors,
  adminAllocateMentorToMentee,
  adminDeallocateMentee,
  adminGetBestMentorSuggestions,
} from "@/app/actions/matching";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

type MentorOption = {
  id: string;
  name: string;
  email: string | null;
  department: string | null;
  currentMenteesCount: number;
  maxMentees: number;
  isAcceptingMentees: boolean;
};

type MenteeRow = {
  id: string;
  name: string;
  email: string;
  department: string;
  currentMentorId: string | null;
  currentMentorName: string | null;
  currentMentorEmail: string | null;
};

type UserMentorRow = {
  id: string;
  name: string;
  email: string;
  department: string;
  assignedMentorName: string | null;
  assignedMentorEmail: string | null;
};

type AdminAllocationPanelProps = {
  mentees: MenteeRow[];
  mentors: MentorOption[];
  allUsers: UserMentorRow[];
};

type SuggestionRow = {
  menteeId: string;
  mentorId: string;
  matchScore: number;
  mentorName: string;
  mentorEmail: string | null;
};

export function AdminAllocationPanel({ mentees, mentors, allUsers }: AdminAllocationPanelProps) {
  const router = useRouter();
  const [busyMenteeId, setBusyMenteeId] = useState<string | null>(null);
  const [bulkBusy, setBulkBusy] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);
  const [suggestionByMenteeId, setSuggestionByMenteeId] = useState<Record<string, SuggestionRow>>({});

  const [selectedMentorByMentee, setSelectedMentorByMentee] = useState<Record<string, string>>(() =>
    Object.fromEntries(mentees.map((mentee) => [mentee.id, mentee.currentMentorId ?? ""])),
  );

  const mentorOptionsById = useMemo(() => {
    const map = new Map<string, MentorOption>();
    for (const mentor of mentors) {
      map.set(mentor.id, mentor);
    }
    return map;
  }, [mentors]);

  const menteeIds = useMemo(() => mentees.map((mentee) => mentee.id), [mentees]);

  const loadSuggestions = async () => {
    if (menteeIds.length === 0) {
      setSuggestionByMenteeId({});
      return;
    }

    setBulkBusy(true);
    setErrorMessage(null);

    try {
      const result = await adminGetBestMentorSuggestions(menteeIds);
      const suggestions = (result?.data || []) as SuggestionRow[];

      const nextSuggestionByMentee = Object.fromEntries(
        suggestions.map((item) => [item.menteeId, item]),
      ) as Record<string, SuggestionRow>;

      setSuggestionByMenteeId(nextSuggestionByMentee);
      setSelectedMentorByMentee((previous) => {
        const next = { ...previous };
        for (const suggestion of suggestions) {
          if (!next[suggestion.menteeId]) {
            next[suggestion.menteeId] = suggestion.mentorId;
          }
        }
        return next;
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : "Failed to generate mentor suggestions.";
      setErrorMessage(message);
    } finally {
      setBulkBusy(false);
    }
  };

  useEffect(() => {
    void loadSuggestions();
  }, [menteeIds.join(",")]);

  const runAllocate = async (mentee: MenteeRow) => {
    const mentorId = selectedMentorByMentee[mentee.id];
    if (!mentorId) {
      setErrorMessage(`Select a mentor before allocating ${mentee.name}.`);
      setSuccessMessage(null);
      return;
    }

    const mentor = mentorOptionsById.get(mentorId);
    if (!mentor) {
      setErrorMessage("Selected mentor could not be found.");
      setSuccessMessage(null);
      return;
    }

    setBusyMenteeId(mentee.id);
    setErrorMessage(null);
    setSuccessMessage(null);

    try {
      const result = await adminAllocateMentorToMentee(mentee.id, mentorId);
      if (!result?.success) {
        throw new Error("Failed to allocate mentor.");
      }

      setSuccessMessage(
        result.message || `Allocated ${mentor.name} to ${mentee.name}.`,
      );
      router.refresh();
    } catch (error) {
      const message = error instanceof Error ? error.message : "Failed to allocate mentor.";
      setErrorMessage(message);
    } finally {
      setBusyMenteeId(null);
    }
  };

  const runDeallocate = async (mentee: MenteeRow) => {
    setBusyMenteeId(mentee.id);
    setErrorMessage(null);
    setSuccessMessage(null);

    try {
      const result = await adminDeallocateMentee(mentee.id);
      if (!result?.success) {
        throw new Error("Failed to deallocate mentor.");
      }

      setSuccessMessage(result.message || `Deallocated mentor for ${mentee.name}.`);
      router.refresh();
    } catch (error) {
      const message = error instanceof Error ? error.message : "Failed to deallocate mentor.";
      setErrorMessage(message);
    } finally {
      setBusyMenteeId(null);
    }
  };

  const runAllocateAllSuggested = async () => {
    if (menteeIds.length === 0) {
      return;
    }

    setBulkBusy(true);
    setErrorMessage(null);
    setSuccessMessage(null);

    try {
      const result = await adminAllocateAllSuggestedMentors(menteeIds);
      if (!result?.success) {
        throw new Error("Failed to allocate all suggested mentors.");
      }

      setSuccessMessage(
        `${result.message} Skipped ${result.skippedCount} mentee(s).`,
      );
      router.refresh();
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "Failed to allocate all suggested mentors.";
      setErrorMessage(message);
    } finally {
      setBulkBusy(false);
    }
  };

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <div className="flex flex-wrap items-center justify-between gap-3">
            <CardTitle className="font-mono text-base">Manual Mentor Allocation</CardTitle>
            <div className="flex items-center gap-2">
              <Button variant="outline" onClick={loadSuggestions} disabled={bulkBusy || Boolean(busyMenteeId)}>
                Refresh Suggestions
              </Button>
              <Button onClick={runAllocateAllSuggested} disabled={bulkBusy || Boolean(busyMenteeId)}>
                {bulkBusy ? "Working..." : "Allocate All Suggested"}
              </Button>
            </div>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          {errorMessage ? (
            <div className="rounded-md border border-destructive/40 bg-destructive/10 p-3 text-sm text-destructive">
              {errorMessage}
            </div>
          ) : null}

          {successMessage ? (
            <div className="rounded-md border border-emerald-400/40 bg-emerald-500/10 p-3 text-sm text-emerald-700 dark:text-emerald-300">
              {successMessage}
            </div>
          ) : null}

          <div className="overflow-x-auto rounded-md border">
            <table className="w-full min-w-[920px] text-sm">
              <thead className="bg-muted/40 text-left">
                <tr>
                  <th className="px-3 py-2 font-medium">Mentee</th>
                  <th className="px-3 py-2 font-medium">Suggested (Best)</th>
                  <th className="px-3 py-2 font-medium">Current Mentor</th>
                  <th className="px-3 py-2 font-medium">Select Mentor</th>
                  <th className="px-3 py-2 font-medium">Actions</th>
                </tr>
              </thead>
              <tbody>
                {mentees.map((mentee) => {
                  const selectedMentorId = selectedMentorByMentee[mentee.id] ?? "";
                  const isBusy = busyMenteeId === mentee.id;
                  const suggestion = suggestionByMenteeId[mentee.id];

                  return (
                    <tr key={mentee.id} className="border-t align-top">
                      <td className="space-y-1 px-3 py-3">
                        <p className="font-medium">{mentee.name}</p>
                        <p className="text-xs text-muted-foreground">{mentee.email}</p>
                        <p className="text-xs text-muted-foreground">{mentee.department}</p>
                      </td>

                      <td className="space-y-1 px-3 py-3">
                        {suggestion ? (
                          <>
                            <p className="font-medium">{suggestion.mentorName}</p>
                            <p className="text-xs text-muted-foreground">{suggestion.mentorEmail || "No email"}</p>
                            <p className="text-xs text-muted-foreground">Score: {suggestion.matchScore.toFixed(3)}</p>
                            <Button
                              size="sm"
                              variant="outline"
                              onClick={() =>
                                setSelectedMentorByMentee((previous) => ({
                                  ...previous,
                                  [mentee.id]: suggestion.mentorId,
                                }))
                              }
                              disabled={isBusy || bulkBusy}
                            >
                              Use Suggestion
                            </Button>
                          </>
                        ) : (
                          <Badge variant="outline">No suggestion</Badge>
                        )}
                      </td>

                      <td className="space-y-1 px-3 py-3">
                        {mentee.currentMentorName ? (
                          <>
                            <p className="font-medium">{mentee.currentMentorName}</p>
                            <p className="text-xs text-muted-foreground">
                              {mentee.currentMentorEmail || "No email"}
                            </p>
                          </>
                        ) : (
                          <Badge variant="outline">Not assigned</Badge>
                        )}
                      </td>

                      <td className="px-3 py-3">
                        <select
                          className="h-9 w-full rounded-md border border-input bg-background px-2 text-sm"
                          value={selectedMentorId}
                          onChange={(event) =>
                            setSelectedMentorByMentee((previous) => ({
                              ...previous,
                              [mentee.id]: event.target.value,
                            }))
                          }
                          disabled={isBusy}
                        >
                          <option value="">Select mentor</option>
                          {mentors.map((mentor) => (
                            <option key={mentor.id} value={mentor.id}>
                              {mentor.name} ({mentor.currentMenteesCount}/{mentor.maxMentees})
                              {mentor.isAcceptingMentees ? "" : " - paused"}
                            </option>
                          ))}
                        </select>
                      </td>

                      <td className="space-x-2 px-3 py-3">
                        <Button
                          size="sm"
                          onClick={() => runAllocate(mentee)}
                          disabled={isBusy || bulkBusy}
                        >
                          {isBusy ? "Saving..." : "Allocate"}
                        </Button>
                        <Button
                          size="sm"
                          variant="outline"
                          onClick={() => runDeallocate(mentee)}
                          disabled={isBusy || bulkBusy}
                        >
                          Deallocate
                        </Button>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="font-mono text-base">All Users and Current Mentor</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto rounded-md border">
            <table className="w-full min-w-[900px] text-sm">
              <thead className="bg-muted/40 text-left">
                <tr>
                  <th className="px-3 py-2 font-medium">User</th>
                  <th className="px-3 py-2 font-medium">Department</th>
                  <th className="px-3 py-2 font-medium">Assigned Mentor</th>
                </tr>
              </thead>
              <tbody>
                {allUsers.map((user) => (
                  <tr key={user.id} className="border-t align-top">
                    <td className="space-y-1 px-3 py-3">
                      <p className="font-medium">{user.name}</p>
                      <p className="text-xs text-muted-foreground">{user.email}</p>
                    </td>
                    <td className="px-3 py-3 text-muted-foreground">{user.department}</td>
                    <td className="space-y-1 px-3 py-3">
                      {user.assignedMentorName ? (
                        <>
                          <p className="font-medium">{user.assignedMentorName}</p>
                          <p className="text-xs text-muted-foreground">
                            {user.assignedMentorEmail || "No email"}
                          </p>
                        </>
                      ) : (
                        <Badge variant="outline">No mentor</Badge>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
