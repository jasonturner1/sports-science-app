import { type NextRequest } from "next/server";
import { updateSession } from "@/lib/supabase/middleware";

export async function middleware(request: NextRequest) {
  return await updateSession(request);
}

export const config = {
  matcher: [
    // Skip auth pages so they never hit Supabase in Edge (avoids 404/500 from middleware)
    "/((?!_next/static|_next/image|favicon.ico|auth|login|signup|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};
