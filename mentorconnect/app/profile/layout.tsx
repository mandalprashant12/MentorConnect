import { AppShell } from "@/components/workspace/app-shell";
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";

export default async function ProfileLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/auth/login");
  }

  return <AppShell userEmail={user.email}>{children}</AppShell>;
}
