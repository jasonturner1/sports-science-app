export type UserRole = "coach" | "athlete";
export type SurfaceType = "grass" | "track";

export interface Profile {
  id: string;
  full_name: string | null;
  role: UserRole;
  athlete_id: string | null;
  created_at: string;
  updated_at: string;
}

export interface Athlete {
  id: string;
  name: string;
  created_at: string;
  updated_at: string;
}

export interface Squad {
  id: string;
  name: string;
  coach_id: string;
  created_at: string;
  updated_at: string;
}

export interface SquadGroup {
  id: string;
  squad_id: string;
  name: string;
  colour: string;
  sort_order: number;
  created_at: string;
}

export interface AthleteSquadMembership {
  id: string;
  athlete_id: string;
  squad_id: string;
  created_at: string;
}

export interface AthleteMasOverride {
  id: string;
  athlete_id: string;
  override_mas: number;
  reason: string | null;
  set_by: string;
  set_at: string;
  created_at: string;
}

export interface TimeTrial {
  id: string;
  athlete_id: string;
  distance_m: number;
  minutes: number;
  seconds: number;
  trial_date: string;
  surface_type: SurfaceType;
  recorded_by: string | null;
  created_at: string;
}

export interface SessionTemplate {
  id: string;
  name: string;
  coach_id: string;
  mas_percent: number;
  shuttle: boolean;
  sets: number;
  on_sec: number;
  off_sec: number;
  efforts: number;
  rest_between_sets_m: number;
  created_at: string;
}

export interface SessionHistory {
  id: string;
  squad_id: string;
  template_id: string | null;
  name: string | null;
  mas_percent: number;
  shuttle: boolean;
  sets: number;
  on_sec: number;
  off_sec: number;
  efforts: number;
  rest_between_sets_m: number;
  summary_duration_m: number;
  created_by: string;
  created_at: string;
}

export interface SessionGroupOutput {
  id: string;
  session_id: string;
  squad_group_id: string;
  metres: number;
  distance_m: number;
  speed_kmh: number;
  pace_min_km: string;
  sort_order: number;
  created_at: string;
}
