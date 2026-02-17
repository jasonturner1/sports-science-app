-- Fix "Database error saving new user": run trigger in auth schema so insert into public.profiles succeeds.
-- See: https://github.com/supabase/supabase/issues/563 (auth schema + SECURITY DEFINER)
-- Drop existing trigger that used public function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create trigger function in auth schema (runs with correct privileges on auth.users insert)
CREATE OR REPLACE FUNCTION auth.handle_new_user()
RETURNS trigger AS $$
DECLARE
  user_role public.user_role;
  link_athlete_id uuid;
  role_raw text;
BEGIN
  role_raw := LOWER(TRIM(COALESCE(NEW.raw_user_meta_data->>'role', '')::text));
  IF role_raw = 'athlete' THEN
    user_role := 'athlete';
  ELSE
    user_role := 'coach';
  END IF;

  BEGIN
    link_athlete_id := (NEW.raw_user_meta_data->>'athlete_id')::uuid;
  EXCEPTION WHEN OTHERS THEN
    link_athlete_id := NULL;
  END;

  INSERT INTO public.profiles (id, full_name, role, athlete_id)
  VALUES (
    NEW.id,
    COALESCE(NULLIF(TRIM(NEW.raw_user_meta_data->>'full_name'), ''), split_part(NEW.email, '@', 1)),
    user_role,
    CASE WHEN user_role = 'athlete' THEN link_athlete_id ELSE NULL END
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Recreate trigger to use auth schema function
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION auth.handle_new_user();
