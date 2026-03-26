import { IssueForm } from "../components/IssueForm";

export default function CreateIssuePage() {
  return (
    <div className="container mx-auto py-8">
      <h1 className="text-3xl font-bold tracking-tight mb-8">Create Issue</h1>
      <IssueForm />
    </div>
  );
}
