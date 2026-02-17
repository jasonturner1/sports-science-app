-- Sports Science App - Initial Schema
-- Run this migration in Supabase SQL Editor or via `supabase db push`

-- Custom types
CREATE TYPE user_role AS ENUM ('coach', 'athlete');
CREATE TYPE surface_type AS ENUM ('grass', 'track');

-- Athletes (no FK to profiles - profiles references athletes)
CREATE TABLE athletes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Profiles (extends auth.users)
CREATE TABLE profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name text,
  role user_role NOT NULL DEFAULT 'coach',
  athlete_id uuid REFERENCES athletes(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT athlete_id_only_for_athletes CHECK (
    (role = 'coach' AND athlete_id IS NULL) OR
    (role = 'athlete')
  )
);

-- Squads
CREATE TABLE squads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  coach_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Athlete-Squad memberships (many-to-many)
CREATE TABLE athlete_squad_memberships (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  athlete_id uuid NOT NULL REFERENCES athletes(id) ON DELETE CASCADE,
  squad_id uuid NOT NULL REFERENCES squads(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(athlete_id, squad_id)
);

-- Squad groups (1-12 per squad)
CREATE TABLE squad_groups (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  squad_id uuid NOT NULL REFERENCES squads(id) ON DELETE CASCADE,
  name text NOT NULL,
  colour text NOT NULL DEFAULT '#FFFFFF',
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Athlete MAS overrides (e.g. post-injury)
CREATE TABLE athlete_mas_overrides (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  athlete_id uuid NOT NULL REFERENCES athletes(id) ON DELETE CASCADE,
  override_mas numeric NOT NULL,
  reason text,
  set_by uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  set_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Time trials
CREATE TABLE time_trials (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  athlete_id uuid NOT NULL REFERENCES athletes(id) ON DELETE CASCADE,
  distance_m numeric NOT NULL,
  minutes integer NOT NULL,
  seconds numeric NOT NULL,
  trial_date date NOT NULL,
  surface_type surface_type NOT NULL,
  recorded_by uuid REFERENCES profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Session templates (favourites)
CREATE TABLE session_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  coach_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  mas_percent numeric NOT NULL DEFAULT 100,
  shuttle boolean NOT NULL DEFAULT false,
  sets integer NOT NULL DEFAULT 1,
  on_sec integer NOT NULL,
  off_sec integer NOT NULL,
  efforts integer NOT NULL,
  rest_between_sets_m integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Session history (generated runs)
CREATE TABLE session_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  squad_id uuid NOT NULL REFERENCES squads(id) ON DELETE CASCADE,
  template_id uuid REFERENCES session_templates(id) ON DELETE SET NULL,
  name text,
  mas_percent numeric NOT NULL,
  shuttle boolean NOT NULL,
  sets integer NOT NULL,
  on_sec integer NOT NULL,
  off_sec integer NOT NULL,
  efforts integer NOT NULL,
  rest_between_sets_m integer NOT NULL,
  summary_duration_m integer NOT NULL,
  created_by uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Session group outputs (per-group results)
CREATE TABLE session_group_outputs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id uuid NOT NULL REFERENCES session_history(id) ON DELETE CASCADE,
  squad_group_id uuid NOT NULL REFERENCES squad_groups(id) ON DELETE CASCADE,
  metres numeric NOT NULL,
  distance_m numeric NOT NULL,
  speed_kmh numeric NOT NULL,
  pace_min_km text NOT NULL,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Indexes for common queries
CREATE INDEX idx_athlete_squad_memberships_athlete ON athlete_squad_memberships(athlete_id);
CREATE INDEX idx_athlete_squad_memberships_squad ON athlete_squad_memberships(squad_id);
CREATE INDEX idx_squad_groups_squad ON squad_groups(squad_id);
CREATE INDEX idx_time_trials_athlete_date ON time_trials(athlete_id, trial_date DESC);
CREATE INDEX idx_athlete_mas_overrides_athlete ON athlete_mas_overrides(athlete_id);
CREATE INDEX idx_session_history_squad ON session_history(squad_id);
CREATE INDEX idx_session_group_outputs_session ON session_group_outputs(session_id);
