-- Auto-create profile when user signs up
-- For athletes: pass athlete_id in meta when inviting to link profile to athlete
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
  user_role user_role;
  link_athlete_id uuid;
BEGIN
  user_role := COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'coach');
  link_athlete_id := (NEW.raw_user_meta_data->>'athlete_id')::uuid;

  INSERT INTO public.profiles (id, full_name, role, athlete_id)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    user_role,
    CASE WHEN user_role = 'athlete' THEN link_athlete_id ELSE NULL END
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
