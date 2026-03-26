"use client";

import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { useEffect, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

interface Comment {
  id: string;
  body: string;
  created_at: string;
  author_id: string;
}

export function CommentSection({ issueId }: { issueId: string }) {
  const supabase = createClient();
  const [comments, setComments] = useState<Comment[]>([]);
  const [newComment, setNewComment] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchComments();
  }, [issueId]);

  async function fetchComments() {
    const { data } = await supabase
      .from("issue_comments")
      .select("*")
      .eq("issue_id", issueId)
      .order("created_at", { ascending: true });

    if (data) {
      setComments(data);
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!newComment.trim()) return;

    setLoading(true);
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
      setLoading(false);
      return;
    }

    const { error } = await supabase.from("issue_comments").insert({
      body: newComment,
      issue_id: issueId,
      author_id: user.id,
    });

    if (!error) {
      setNewComment("");
      fetchComments();
    }
    setLoading(false);
  }

  return (
    <div className="space-y-6 mt-8">
      <Card>
        <CardHeader>
          <CardTitle>Comments</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {comments.length === 0 ? (
            <p className="text-muted-foreground text-sm">No comments yet.</p>
          ) : (
            comments.map((comment) => (
              <div
                key={comment.id}
                className="p-4 rounded-lg bg-muted/50 text-sm space-y-2"
              >
                <p>{comment.body}</p>
                <p className="text-xs text-muted-foreground">
                  {new Date(comment.created_at).toLocaleString()}
                </p>
              </div>
            ))
          )}

          <form onSubmit={handleSubmit} className="space-y-4 mt-6">
            <textarea
              value={newComment}
              onChange={(e) => setNewComment(e.target.value)}
              placeholder="Add a comment..."
              className="flex min-h-[80px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
              disabled={loading}
            />
            <Button type="submit" disabled={loading || !newComment.trim()}>
              {loading ? "Posting..." : "Post Comment"}
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
