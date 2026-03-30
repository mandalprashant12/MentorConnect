"use client";

import { useState } from "react";
import { confirmMentorAllocation, runMatchingAlgorithm } from "@/app/actions/matching";
import { Button } from "@/components/ui/button";
import { useRouter } from "next/navigation";

type MatchResultPayload = {
  success?: boolean;
  count?: number;
  allocatedMentor?: {
    mentorId: string;
    mentorName?: string;
    mentorEmail?: string | null;
    mentorDepartment?: string | null;
    matchScore: number;
  } | null;
  error?: string;
  [key: string]: unknown;
};

type AllocationResultPayload = {
  success?: boolean;
  alreadyAssigned?: boolean;
  message?: string;
  mentorName?: string;
  mentorEmail?: string | null;
  mentorDepartment?: string | null;
  groupId?: string;
  activeMenteeCount?: number;
  error?: string;
};

export function TriggerMatchingButton() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [allocating, setAllocating] = useState(false);
  const [result, setResult] = useState<MatchResultPayload | null>(null);
  const [allocationResult, setAllocationResult] = useState<AllocationResultPayload | null>(null);

  const handleMatch = async () => {
    setLoading(true);
    setAllocationResult(null);
    try {
      const res = await runMatchingAlgorithm();
      setResult(res);
    } catch (error: any) {
      setResult({ error: error.message });
    }
    setLoading(false);
  };

  const handleConfirmAllocation = async () => {
    if (!result?.allocatedMentor?.mentorId) return;

    setAllocating(true);
    try {
      const response = await confirmMentorAllocation(result.allocatedMentor.mentorId);
      setAllocationResult(response);
      if (response?.success) {
        router.refresh();
      }
    } catch (error: any) {
      setAllocationResult({
        success: false,
        error: error?.message || "Failed to confirm allocation.",
      });
    }
    setAllocating(false);
  };

  return (
    <div className="flex flex-col gap-2 p-4 bg-muted/50 rounded-lg mt-4 border border-border">
      <h3 className="font-semibold text-lg">Test Match Algorithm</h3>
      <p className="text-sm text-muted-foreground">
        Click to run the matching algorithm and generate mentor predictions for this user.
      </p>
      <Button onClick={handleMatch} disabled={loading} className="w-fit">
        {loading ? "Running..." : "Run Matching Algorithm"}
      </Button>
      {result?.success && result.allocatedMentor ? (
        <div className="mt-3 rounded-md border bg-card p-3 text-sm">
          <p className="font-semibold text-foreground">Allocated Mentor</p>
          <p className="mt-1 text-muted-foreground">
            {result.allocatedMentor.mentorName || "Unknown mentor"}
          </p>
          <p className="text-xs text-muted-foreground">
            Score: {(result.allocatedMentor.matchScore * 100).toFixed(1)}%
          </p>
          {result.allocatedMentor.mentorEmail ? (
            <p className="text-xs text-muted-foreground">Email: {result.allocatedMentor.mentorEmail}</p>
          ) : null}
          {result.allocatedMentor.mentorDepartment ? (
            <p className="text-xs text-muted-foreground">
              Department: {result.allocatedMentor.mentorDepartment}
            </p>
          ) : null}
          <Button
            onClick={handleConfirmAllocation}
            disabled={allocating}
            className="mt-3 w-fit"
            size="sm"
          >
            {allocating ? "Confirming..." : "Confirm Allocation"}
          </Button>
          {allocationResult?.success ? (
            <p className="mt-2 text-xs text-green-600">
              {allocationResult.message}
              {allocationResult.groupId ? ` Group: ${allocationResult.groupId}` : ""}
            </p>
          ) : null}
          {allocationResult?.error ? (
            <p className="mt-2 text-xs text-red-600">{allocationResult.error}</p>
          ) : null}
        </div>
      ) : null}
      {result && (
        <pre className="mt-4 p-4 bg-black text-green-400 text-xs rounded overflow-auto max-h-60">
          {JSON.stringify(result, null, 2)}
        </pre>
      )}
    </div>
  );
}
