-- Row Level Security (RLS) Policies
-- Enables RLS on all tables and adds coach/athlete access policies

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE athletes ENABLE ROW LEVEL SECURITY;
ALTER TABLE squads ENABLE ROW LEVEL SECURITY;
ALTER TABLE athlete_squad_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE squad_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE athlete_mas_overrides ENABLE ROW LEVEL SECURITY;
ALTER TABLE time_trials ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_group_outputs ENABLE ROW LEVEL SECURITY;

-- Helper functions in public schema (auth schema is reserved by Supabase)
-- Get current user's role
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS user_role AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid()
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Check if user is coach of a squad
CREATE OR REPLACE FUNCTION public.is_squad_coach(squad_uuid uuid)
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM squads WHERE id = squad_uuid AND coach_id = auth.uid()
  )
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Check if user (athlete) is in squad
CREATE OR REPLACE FUNCTION public.athlete_in_squad(squad_uuid uuid)
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles p
    JOIN athlete_squad_memberships m ON m.athlete_id = p.athlete_id
    WHERE p.id = auth.uid() AND m.squad_id = squad_uuid
  )
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Get athlete_id for current user (if athlete)
CREATE OR REPLACE FUNCTION public.my_athlete_id()
RETURNS uuid AS $$
  SELECT athlete_id FROM public.profiles WHERE id = auth.uid() AND role = 'athlete'
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- PROFILES: users can read/update own row
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (id = auth.uid());

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (id = auth.uid());

-- SQUADS: coaches full access to own; athletes read squads they're in
CREATE POLICY "Coaches can manage own squads" ON squads
  FOR ALL USING (coach_id = auth.uid());

CREATE POLICY "Athletes can view squads they're in" ON squads
  FOR SELECT USING (public.athlete_in_squad(id));

-- ATHLETES: coaches CRUD for athletes in their squads; athletes read own
CREATE POLICY "Coaches can manage athletes in their squads" ON athletes
  FOR ALL USING (
    public.get_user_role() = 'coach' AND EXISTS (
      SELECT 1 FROM athlete_squad_memberships m
      JOIN squads s ON s.id = m.squad_id
      WHERE m.athlete_id = athletes.id AND s.coach_id = auth.uid()
    )
  );

CREATE POLICY "Athletes can view own record" ON athletes
  FOR SELECT USING (id = public.my_athlete_id());

-- ATHLETE_SQUAD_MEMBERSHIPS
CREATE POLICY "Coaches can manage memberships for their squads" ON athlete_squad_memberships
  FOR ALL USING (public.is_squad_coach(squad_id));

CREATE POLICY "Athletes can view own memberships" ON athlete_squad_memberships
  FOR SELECT USING (athlete_id = public.my_athlete_id());

-- SQUAD_GROUPS
CREATE POLICY "Coaches can manage groups for their squads" ON squad_groups
  FOR ALL USING (public.is_squad_coach(squad_id));

CREATE POLICY "Athletes can view groups of their squads" ON squad_groups
  FOR SELECT USING (public.athlete_in_squad(squad_id));

-- ATHLETE_MAS_OVERRIDES
CREATE POLICY "Coaches can manage overrides for athletes in their squads" ON athlete_mas_overrides
  FOR ALL USING (
    public.get_user_role() = 'coach' AND EXISTS (
      SELECT 1 FROM athlete_squad_memberships m
      JOIN squads s ON s.id = m.squad_id
      WHERE m.athlete_id = athlete_mas_overrides.athlete_id AND s.coach_id = auth.uid()
    )
  );

CREATE POLICY "Athletes can view own override" ON athlete_mas_overrides
  FOR SELECT USING (athlete_id = public.my_athlete_id());

-- TIME_TRIALS
CREATE POLICY "Coaches can manage trials for athletes in their squads" ON time_trials
  FOR ALL USING (
    public.get_user_role() = 'coach' AND EXISTS (
      SELECT 1 FROM athlete_squad_memberships m
      JOIN squads s ON s.id = m.squad_id
      WHERE m.athlete_id = time_trials.athlete_id AND s.coach_id = auth.uid()
    )
  );

CREATE POLICY "Athletes can view own trials" ON time_trials
  FOR SELECT USING (athlete_id = public.my_athlete_id());

-- SESSION_TEMPLATES: coaches only
CREATE POLICY "Coaches can manage own templates" ON session_templates
  FOR ALL USING (coach_id = auth.uid());

-- SESSION_HISTORY
CREATE POLICY "Coaches can manage session history for their squads" ON session_history
  FOR ALL USING (public.is_squad_coach(squad_id));

CREATE POLICY "Athletes can view session history for their squads" ON session_history
  FOR SELECT USING (public.athlete_in_squad(squad_id));

-- SESSION_GROUP_OUTPUTS: via session
CREATE POLICY "Coaches can manage outputs for their squads" ON session_group_outputs
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM session_history sh
      WHERE sh.id = session_group_outputs.session_id AND public.is_squad_coach(sh.squad_id)
    )
  );

CREATE POLICY "Athletes can view outputs for their squads" ON session_group_outputs
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM session_history sh
      JOIN athlete_squad_memberships m ON m.squad_id = sh.squad_id
      WHERE sh.id = session_group_outputs.session_id
        AND m.athlete_id = public.my_athlete_id()
    )
  );
