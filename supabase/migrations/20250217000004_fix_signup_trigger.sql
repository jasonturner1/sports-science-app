-- Fix signup: allow profile insert and harden trigger
-- 1) Allow insert into profiles when the row id matches the current user (for trigger/signup flow)
CREATE POLICY "Allow insert own profile on signup"
  ON profiles FOR INSERT
  WITH CHECK (id = auth.uid());

-- 2) Harden handle_new_user: normalize role (lowercase), default coach, safe athlete_id
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
  user_role user_role;
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
$$ LANGUAGE plpgsql SECURITY DEFINER;
