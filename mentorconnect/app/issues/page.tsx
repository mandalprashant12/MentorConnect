import { createClient } from "@/lib/supabase/server";
import { IssueCard } from "./components/IssueCard";
import { Button } from "@/components/ui/button";
import Link from "next/link";

export default async function IssuesPage() {
  const supabase = await createClient();

  const { data: issues } = await supabase
    .from("issues")
    .select("*")
    .order("created_at", { ascending: false });

  return (
    <div className="container mx-auto py-8 space-y-8">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold tracking-tight">Issues</h1>
        <Link href="/issues/create">
          <Button>New Issue</Button>
        </Link>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {issues?.map((issue) => (
          <IssueCard key={issue.id} issue={issue} />
        ))}
      </div>
    </div>
  );
}
