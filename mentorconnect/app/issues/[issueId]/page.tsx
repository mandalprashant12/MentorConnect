import { createClient } from "@/lib/supabase/server";
import { Badge } from "@/components/ui/badge";
import { CommentSection } from "../components/CommentSection";
import { notFound } from "next/navigation";
import { Suspense } from "react";

export default async function IssuePage({
  params,
}: {
  params: Promise<{ issueId: string }>;
}) {
  const { issueId } = await params;
  const supabase = await createClient();
  const { data: issue } = await supabase
    .from("issues")
    .select("*")
    .eq("id", issueId)
    .single();

  if (!issue) {
    notFound();
  }

  return (
    <div className="container mx-auto py-8 max-w-4xl">
      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <h1 className="text-3xl font-bold tracking-tight">{issue.title}</h1>
          <Badge variant={issue.status === "closed" ? "secondary" : "default"}>
            {issue.status}
          </Badge>
        </div>

        <div className="text-sm text-muted-foreground">
          Opened on {new Date(issue.created_at).toLocaleDateString()}
        </div>

        <div className="prose dark:prose-invert max-w-none mt-8 p-6 border rounded-lg bg-card text-card-foreground">
          <p className="whitespace-pre-wrap">{issue.description}</p>
        </div>

        <div className="mt-12">
          <h2 className="text-2xl font-semibold mb-6">Comments</h2>
          <Suspense fallback={<p className="text-sm text-muted-foreground">Loading comments...</p>}>
            <CommentSection issueId={issueId} />
          </Suspense>
        </div>
      </div>
    </div>
  );
}

