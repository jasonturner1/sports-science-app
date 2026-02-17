declare module "@supabase/ssr" {
  import { SupabaseClient } from "@supabase/supabase-js";

  export function createBrowserClient(
    url: string,
    key: string
  ): SupabaseClient;

  export function createServerClient(
    url: string,
    key: string,
    options: {
      cookies: {
        getAll(): { name: string; value: string }[];
        setAll(cookies: { name: string; value: string; options?: object }[]): void;
      };
    }
  ): SupabaseClient;
}
