"use client";

import { createClient } from "@/lib/supabase/client";
import { useRouter } from "next/navigation";

export function SignOutButton() {
  const router = useRouter();
  return (
    <button
      type="button"
      onClick={async () => {
        const supabase = createClient();
        await supabase.auth.signOut();
        router.push("/");
        router.refresh();
      }}
      className="rounded-lg border border-slate-300 px-4 py-2 font-medium text-slate-700 hover:bg-slate-100"
    >
      Sign out
    </button>
  );
}
