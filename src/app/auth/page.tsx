"use client";

import { useState, Suspense, useEffect } from "react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { useRouter } from "next/navigation";

function AuthForm() {
  const searchParams = useSearchParams();
  const isSignUp = searchParams.get("mode") === "signup";
  const code = searchParams.get("code");

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [fullName, setFullName] = useState("");
  const [role, setRole] = useState<"coach" | "athlete">("coach");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [exchanging, setExchanging] = useState(!!code);
  const router = useRouter();

  // After email verification, Supabase redirects here with ?code=...; exchange it for a session
  useEffect(() => {
    if (!code) return;
    const supabase = createClient();
    supabase.auth.exchangeCodeForSession(code).then(({ error: exchangeError }) => {
      setExchanging(false);
      if (exchangeError) {
        setError(exchangeError.message);
        return;
      }
      router.replace("/");
      router.refresh();
    });
  }, [code, router]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      const supabase = createClient();
      if (isSignUp) {
        // #region agent log
        fetch('http://127.0.0.1:7242/ingest/09fb770f-1565-44fd-8656-e275c319509c',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'auth/page.tsx:signup-before',message:'signup attempt',data:{role,fullNameLength:fullName.length},hypothesisId:'H2',timestamp:Date.now()})}).catch(()=>{});
        // #endregion
        const { data: signUpData, error: signUpError } = await supabase.auth.signUp({
          email,
          password,
          options: {
            data: { full_name: fullName, role },
            emailRedirectTo: typeof window !== "undefined" ? `${window.location.origin}/auth` : undefined,
          },
        });
        if (signUpError) {
          // #region agent log
          fetch('http://127.0.0.1:7242/ingest/09fb770f-1565-44fd-8656-e275c319509c',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'auth/page.tsx:signup-error',message:'signup error from Supabase',data:{message:signUpError.message,name:(signUpError as Error).name,status:(signUpError as { status?: number }).status,code:(signUpError as { code?: string }).code},hypothesisId:'H1,H4,H5',timestamp:Date.now()})}).catch(()=>{});
          // #endregion
          setError(signUpError.message);
          setLoading(false);
          return;
        }
        // #region agent log
        fetch('http://127.0.0.1:7242/ingest/09fb770f-1565-44fd-8656-e275c319509c',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'auth/page.tsx:signup-ok',message:'signup no error',data:{user:!!signUpData?.user},hypothesisId:'H4',timestamp:Date.now()})}).catch(()=>{});
        // #endregion
        setSuccess(true);
        router.refresh();
      } else {
        const { error: signInError } = await supabase.auth.signInWithPassword({
          email,
          password,
        });
        if (signInError) {
          setError(signInError.message);
          setLoading(false);
          return;
        }
        router.push("/");
        router.refresh();
      }
    } catch (err) {
      // #region agent log
      fetch('http://127.0.0.1:7242/ingest/09fb770f-1565-44fd-8656-e275c319509c',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'auth/page.tsx:catch',message:'signup exception',data:{err: String(err), name: err instanceof Error ? err.name : ''},hypothesisId:'H3',timestamp:Date.now()})}).catch(()=>{});
      // #endregion
      setError("Something went wrong. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  if (exchanging) {
    return (
      <div className="w-full max-w-sm space-y-6 text-center">
        <p className="text-slate-600">Confirming your email…</p>
      </div>
    );
  }

  if (success) {
    return (
      <div className="w-full max-w-sm space-y-6 text-center">
        <h1 className="text-2xl font-bold text-slate-900">Check your email</h1>
        <p className="text-slate-600">
          We’ve sent a confirmation link to <strong>{email}</strong>. Click it to
          activate your account, then sign in.
        </p>
        <Link
          href="/auth"
          className="inline-block rounded-lg bg-emerald-600 px-4 py-2 font-medium text-white hover:bg-emerald-700"
        >
          Go to sign in
        </Link>
      </div>
    );
  }

  return (
    <div className="w-full max-w-sm space-y-6">
      <h1 className="text-2xl font-bold text-slate-900 text-center">
        {isSignUp ? "Sign up" : "Sign in"}
      </h1>
      <form onSubmit={handleSubmit} className="space-y-4">
        {isSignUp && (
          <>
            <div>
              <label htmlFor="fullName" className="block text-sm font-medium text-slate-700 mb-1">
                Full name
              </label>
              <input
                id="fullName"
                type="text"
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                required={isSignUp}
                autoComplete="name"
                className="w-full rounded-lg border border-slate-300 px-3 py-2 text-slate-900 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">I am a</label>
              <div className="flex gap-4">
                <label className="flex items-center gap-2 cursor-pointer">
                  <input
                    type="radio"
                    name="role"
                    checked={role === "coach"}
                    onChange={() => setRole("coach")}
                    className="text-emerald-600 focus:ring-emerald-500"
                  />
                  <span className="text-slate-700">Coach</span>
                </label>
                <label className="flex items-center gap-2 cursor-pointer">
                  <input
                    type="radio"
                    name="role"
                    checked={role === "athlete"}
                    onChange={() => setRole("athlete")}
                    className="text-emerald-600 focus:ring-emerald-500"
                  />
                  <span className="text-slate-700">Athlete</span>
                </label>
              </div>
            </div>
          </>
        )}
        <div>
          <label htmlFor="email" className="block text-sm font-medium text-slate-700 mb-1">
            Email
          </label>
          <input
            id="email"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            autoComplete="email"
            className="w-full rounded-lg border border-slate-300 px-3 py-2 text-slate-900 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500"
          />
        </div>
        <div>
          <label htmlFor="password" className="block text-sm font-medium text-slate-700 mb-1">
            Password
          </label>
          <input
            id="password"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            minLength={isSignUp ? 6 : undefined}
            autoComplete={isSignUp ? "new-password" : "current-password"}
            className="w-full rounded-lg border border-slate-300 px-3 py-2 text-slate-900 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500"
          />
        </div>
        {error && <p className="text-sm text-red-600">{error}</p>}
        <button
          type="submit"
          disabled={loading}
          className="w-full rounded-lg bg-emerald-600 px-4 py-2 font-medium text-white hover:bg-emerald-700 disabled:opacity-50"
        >
          {loading
            ? isSignUp
              ? "Creating account…"
              : "Signing in…"
            : isSignUp
              ? "Sign up"
              : "Sign in"}
        </button>
      </form>
      <p className="text-center text-sm text-slate-600">
        {isSignUp ? (
          <>
            Already have an account?{" "}
            <Link href="/auth" className="font-medium text-emerald-600 hover:underline">
              Sign in
            </Link>
          </>
        ) : (
          <>
            Don’t have an account?{" "}
            <Link href="/auth?mode=signup" className="font-medium text-emerald-600 hover:underline">
              Sign up
            </Link>
          </>
        )}
      </p>
    </div>
  );
}

export default function AuthPage() {
  return (
    <main className="min-h-screen bg-slate-50 flex items-center justify-center p-8">
      <Suspense fallback={<div className="text-slate-600">Loading…</div>}>
        <AuthForm />
      </Suspense>
    </main>
  );
}
