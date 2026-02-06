import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";

export default async function ProtectedPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return redirect("/auth/login");
  }

  return (
    <div className="flex flex-col items-center justify-center gap-6 text-center py-20">
      <h1 className="text-4xl font-bold">Welcome, {user.email}!</h1>
      <p className="text-lg text-muted-foreground">
        You are now logged in. This is your landing page.
      </p>
    </div>
  );
}

