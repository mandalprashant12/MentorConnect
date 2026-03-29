import Link from "next/link";
import { Suspense } from "react";
import { AuthButton } from "@/components/auth-button";
import { ThemeSwitcher } from "@/components/theme-switcher";

export default function Home() {
  return (
    <main className="min-h-screen flex flex-col items-center">
      <div className="flex-1 w-full flex flex-col gap-20 items-center">
        <nav className="w-full flex justify-center border-b border-b-foreground/10 h-16">
          <div className="w-full max-w-5xl flex justify-between items-center p-3 px-5 text-sm">
            <div className="flex gap-5 items-center font-semibold text-white">
              <Link href={"/"}>MentorConnect</Link>
            </div>
            <Suspense>
              <AuthButton />
            </Suspense>
          </div>
        </nav>

        <div className="flex-1 flex flex-col items-center justify-center gap-8 max-w-3xl p-5 text-center">
          <h1 className="text-5xl font-bold text-white">
            Connect. Learn. Grow.
          </h1>
          <p className="text-lg text-gray-300 max-w-xl">
            MentorConnect bridges students with the right mentors — whether
            you&apos;re looking for academic help, career guidance, or personal growth.
          </p>
          <div className="flex gap-4 flex-wrap justify-center">
            <Link
              href="/auth/sign-up"
              className="px-8 py-3 rounded-lg font-semibold text-white transition-all"
              style={{ backgroundColor: "#9358be" }}
            >
              Get Started
            </Link>
            <Link
              href="/auth/login"
              className="px-8 py-3 rounded-lg font-semibold border border-white/30 text-white backdrop-blur-sm hover:bg-white/10 transition-all"
            >
              Log In
            </Link>
          </div>
        </div>

        <footer className="w-full flex items-center justify-center border-t border-white/10 mx-auto text-center text-xs gap-8 py-8 text-gray-400">
          <p>MentorConnect &copy; {new Date().getFullYear()}</p>
          <ThemeSwitcher />
        </footer>
      </div>
    </main>
  );
}
