import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { SignOutButton } from "@/components/SignOutButton";

export default async function HomePage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  return (
    <main className="min-h-screen bg-slate-50 p-8">
      <div className="mx-auto max-w-2xl space-y-8">
        <h1 className="text-3xl font-bold text-slate-900">
          Sports Science App
        </h1>
        <p className="text-slate-600">
          Manage athlete time trial data, squads, groups, and training sessions.
        </p>
        {user ? (
          <div className="flex flex-wrap items-center gap-4">
            <p className="text-slate-700">
              Signed in as <strong>{user.email}</strong>
            </p>
            <SignOutButton />
          </div>
        ) : (
          <div className="flex gap-4">
            <Link
              href="/auth"
              className="rounded-lg bg-emerald-600 px-4 py-2 font-medium text-white hover:bg-emerald-700"
            >
              Sign in
            </Link>
            <Link
              href="/auth?mode=signup"
              className="rounded-lg border border-slate-300 px-4 py-2 font-medium text-slate-700 hover:bg-slate-100"
            >
              Sign up
            </Link>
          </div>
        )}
      </div>
    </main>
  );
}
