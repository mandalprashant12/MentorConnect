import { Badge } from "@/components/ui/badge";
import {
  Card,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import Link from "next/link";

interface Issue {
  id: string;
  title: string;
  description: string;
  status: string;
  created_at: string;
}

export function IssueCard({ issue }: { issue: Issue }) {
  return (
    <Link href={`/issues/${issue.id}`}>
      <Card className="hover:bg-accent/50 transition-colors cursor-pointer">
        <CardHeader>
          <div className="flex items-center justify-between">
            <CardTitle className="text-lg">{issue.title}</CardTitle>
            <Badge variant={issue.status === "closed" ? "secondary" : "default"}>
              {issue.status}
            </Badge>
          </div>
          <CardDescription className="line-clamp-2">
            {issue.description}
          </CardDescription>
          <div className="text-xs text-muted-foreground mt-2">
            Created on {new Date(issue.created_at).toLocaleDateString()}
          </div>
        </CardHeader>
      </Card>
    </Link>
  );
}
