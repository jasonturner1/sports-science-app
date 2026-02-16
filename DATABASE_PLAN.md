# Sports Science Web App — Database Plan

## Overview

This document outlines the database structure for a sports science MVP that allows coaches to manage athlete time trial data, group athletes by MAS, configure training sessions, and generate session outputs. Athletes can log in to view their assigned squad and group.

---

## Entity Relationship Summary

```
profiles (coaches + athletes)
    │
    ├── squads (coach-owned)
    │       ├── squad_groups (1–12 groups: name + colour)
    │       └── athlete_squad_memberships (many-to-many)
    │
    ├── athletes (linked to profile if athlete login)
    │       ├── time_trials (history: distance, mins, secs, date, surface)
    │       └── athlete_mas_overrides (manual MAS, e.g. post-injury)
    │
    ├── session_templates (favourite configs, reusable)
    │
    └── session_history (log of generated sessions)
            └── session_group_outputs (per-group metres, speed, pace)
```

---

## Tables

### 1. `profiles`

Extends Supabase Auth (`auth.users`). One row per user (coach or athlete).

| Column       | Type         | Notes                                      |
|-------------|--------------|--------------------------------------------|
| id          | uuid         | PK, FK → `auth.users.id`                   |
| full_name   | text         | Display name                               |
| role        | enum         | `'coach'` \| `'athlete'`                   |
| athlete_id  | uuid         | FK → `athletes.id`, nullable (only if role = athlete) |
| created_at  | timestamptz  |                                            |
| updated_at  | timestamptz  |                                            |

---

### 2. `squads`

Groups of athletes managed by a coach.

| Column     | Type        | Notes                          |
|------------|-------------|--------------------------------|
| id         | uuid        | PK                             |
| name       | text        | e.g. "U16 Boys", "Senior Women" |
| coach_id   | uuid        | FK → `profiles.id`             |
| created_at | timestamptz |                                |
| updated_at | timestamptz |                                |

---

### 3. `athletes`

Athletes can be in multiple squads via `athlete_squad_memberships`.

| Column     | Type        | Notes                          |
|------------|-------------|--------------------------------|
| id         | uuid        | PK                             |
| name       | text        |                                |
| created_at | timestamptz |                                |
| updated_at | timestamptz |                                |

**Note:** Athletes with logins have `profiles.athlete_id` pointing here.

---

### 3b. `athlete_mas_overrides`

Stores manual MAS overrides (e.g. post-injury). **Does not** create a time trial record — it is a separate adjustment for calculations. The UI must clearly indicate when an override is active.

| Column         | Type        | Notes                                      |
|----------------|-------------|--------------------------------------------|
| id             | uuid        | PK                                         |
| athlete_id     | uuid        | FK → `athletes.id`                         |
| override_mas   | numeric     | Effective MAS to use instead of computed   |
| reason         | text        | e.g. "Returning from injury"                |
| set_by         | uuid        | FK → `profiles.id` (coach)                  |
| set_at         | timestamptz | When override was applied                  |
| created_at     | timestamptz |                                            |

**Logic:** One active override per athlete (latest wins, or soft-delete previous when setting new). When `override_mas` is set, use it for session calculations instead of MAS from latest time trial. Override is **not** part of test history — it is an administrative adjustment. The app should surface "Override active" clearly on athlete/session views.

---

### 4. `athlete_squad_memberships`

Many-to-many: athlete ↔ squad. Group assignment is derived at session time from MAS distribution, not stored here.

| Column     | Type        | Notes                          |
|------------|-------------|--------------------------------|
| id         | uuid        | PK                             |
| athlete_id | uuid        | FK → `athletes.id`             |
| squad_id   | uuid        | FK → `squads.id`              |
| created_at | timestamptz |                                |

**Unique constraint:** `(athlete_id, squad_id)` — one membership per athlete per squad.

---

### 5. `squad_groups`

Groups within a squad (1–12). Each has a name and colour. Used for session output.

| Column     | Type        | Notes                                      |
|------------|-------------|--------------------------------------------|
| id         | uuid        | PK                                         |
| squad_id   | uuid        | FK → `squads.id`                           |
| name       | text        | e.g. "WHITE", "BLUE", "RED"                |
| colour     | text        | Hex e.g. `#FFFFFF`, or CSS colour name     |
| sort_order | integer     | Order (1, 2, 3…) for display              |
| created_at | timestamptz |                                            |

**Logic:** Squad defines N groups (1–12). Athletes are sorted by MAS, split into N groups, and each group's midpoint MAS is used for calculations.

---

### 6. `time_trials`

Time trial history per athlete. MAS is computed from these values.

| Column       | Type        | Notes                                      |
|--------------|-------------|--------------------------------------------|
| id           | uuid        | PK                                         |
| athlete_id   | uuid        | FK → `athletes.id`                         |
| distance_m   | numeric     | Distance in metres (D)                     |
| minutes      | integer     | Minutes (M)                                |
| seconds      | numeric     | Seconds (S)                                |
| trial_date   | date        | When the trial was performed               |
| surface_type | enum        | `'grass'` \| `'track'`                     |
| recorded_by  | uuid        | FK → `profiles.id` (coach who entered it)  |
| created_at   | timestamptz |                                            |

**MAS formula (stored or computed):**

```
MAS = D ÷ (M × 60 + S) × (0.766 + 0.117 × (D ÷ 1000))
```

Where: D = `distance_m`, M = `minutes`, S = `seconds`.

---

### MAS source: default vs override

- **Default:** Use MAS computed from the athlete's **latest time trial**.
- **Override:** Coach can set a manual MAS (e.g. post-injury) via `athlete_mas_overrides`.
- When an override exists, use `override_mas` for calculations. The override is **not** a time trial — it is an administrative adjustment. The UI must clearly show when an override is active (e.g. badge, tooltip) so it is obvious the athlete has been modified.

---

### 7. Session variables (used by templates and history)

Session variables are stored in `session_templates` (favourites) and `session_history` (runs). See tables 8–10 below.

---

### 8. `session_templates`

Saved favourite session configurations (variables only). Reusable across squads.

| Column              | Type        | Notes                                      |
|---------------------|-------------|--------------------------------------------|
| id                  | uuid        | PK                                         |
| name                | text        | e.g. "Standard 30-30"                       |
| coach_id            | uuid        | FK → `profiles.id` (owner)                  |
| mas_percent         | numeric     | e.g. 92.5                                  |
| shuttle             | boolean     |                                            |
| sets                | integer     |                                            |
| on_sec              | integer     |                                            |
| off_sec             | integer     |                                            |
| efforts             | integer     |                                            |
| rest_between_sets_m | integer     |                                            |
| created_at          | timestamptz |                                            |

---

### Shuttle logic

For a given effort: **distance = time (sec) × MAS (m/s)**.

With **Shuttle** enabled:
1. Compute normal distance: `distance = time × MAS`
2. Subtract 2 metres (cost of change of direction)
3. Halve the result

**Formula:** `shuttle_distance = (distance - 2) / 2`

**Example:** 10 sec effort at 100% MAS, MAS = 5 m/s  
- Normal: 10 × 5 = **50 m**  
- Shuttle: (50 − 2) ÷ 2 = **24 m**

---

### 9. `session_history`

Log of generated sessions. Each run is stored with its outputs for history.

| Column              | Type        | Notes                                      |
|---------------------|-------------|--------------------------------------------|
| id                  | uuid        | PK                                         |
| squad_id            | uuid        | FK → `squads.id`                           |
| template_id         | uuid        | FK → `session_templates.id`, nullable      |
| name                | text        | Optional run name                          |
| mas_percent         | numeric     | Snapshot of variables used                |
| shuttle             | boolean     |                                            |
| sets                | integer     |                                            |
| on_sec              | integer     |                                            |
| off_sec             | integer     |                                            |
| efforts             | integer     |                                            |
| rest_between_sets_m | integer     |                                            |
| summary_duration_m  | integer     | Total session duration (minutes)           |
| created_by          | uuid        | FK → `profiles.id`                         |
| created_at          | timestamptz |                                            |

---

### 10. `session_group_outputs`

Per-group outputs for a session run. Stored for history.

| Column         | Type        | Notes                          |
|----------------|-------------|--------------------------------|
| id             | uuid        | PK                             |
| session_id     | uuid        | FK → `session_history.id`      |
| squad_group_id | uuid        | FK → `squad_groups.id`         |
| metres         | numeric     | Calculated total metres        |
| distance_m     | numeric     | Per-effort distance            |
| speed_kmh      | numeric     | Speed km/h                     |
| pace_min_km    | text        | Pace e.g. "3:26"               |
| sort_order     | integer     | Display order                  |
| created_at     | timestamptz |                                |

---

## Data Flow (Step-by-Step)

### 1. Coach creates squad and groups

- Create `squads` row (coach_id = current user).
- Create `squad_groups` rows (1–12) with name and colour.

### 2. Coach adds athletes to squad

- Create `athletes` if new.
- Create `athlete_squad_memberships` (athlete_id, squad_id).

### 3. Coach records time trials

- Insert `time_trials` (athlete_id, distance_m, minutes, seconds, trial_date, surface_type).
- MAS is computed from D, M, S using the formula.

### 4. Coach creates/configures a session

- Use session builder UI with variables (MAS %, Shuttle, Sets, ON, OFF, Efforts, Rest).
- Optionally save as **template** (favourite) → `session_templates`.
- When generating a run → create `session_history` + `session_group_outputs`.

### 5. Session output calculation

1. Get athletes in squad via `athlete_squad_memberships`.
2. For each athlete, get **effective MAS**: latest time trial (or `athlete_mas_overrides.override_mas` if set).
3. Sort athletes by MAS, split into N groups (from `squad_groups`).
4. For each group, compute midpoint MAS.
5. Apply session variables:
   - Effective MAS = midpoint × (mas_percent / 100)
   - Per-effort distance = ON (sec) × effective MAS (m/s)
   - If shuttle: `(distance - 2) / 2`
6. Compute per-group: metres, distance, speed, pace.
7. Compute session summary: total duration, sets, ON/OFF structure.
8. Save to `session_history` + `session_group_outputs` for history.

### 6. Athlete login view

- `profiles.athlete_id` → `athletes`.
- `athlete_squad_memberships` → squads they're in.
- Group assignment = computed from current MAS distribution for that squad.
- Show session output for their squad/group (read-only).
- If athlete has MAS override, coach sees "Override active"; athlete may see their effective targets.

---

## Row Level Security (RLS)

| Table                    | Coach access                          | Athlete access                          |
|--------------------------|---------------------------------------|----------------------------------------|
| profiles                 | Own row                               | Own row                                 |
| squads                   | Own squads (coach_id = auth.uid)      | Read squads they're in                  |
| athletes                 | Full CRUD for athletes in their squads| Read own athlete row                    |
| athlete_squad_memberships| CRUD for their squads                 | Read own memberships                    |
| athlete_mas_overrides     | CRUD for athletes in their squads     | Read own override (if any)               |
| squad_groups             | CRUD for their squads                 | Read groups of squads they're in        |
| time_trials              | CRUD for athletes in their squads     | Read own time trials                    |
| session_templates        | CRUD own templates                    | —                                       |
| session_history          | CRUD for their squads                 | Read sessions for squads they're in     |
| session_group_outputs    | Via session_history                   | Read via session_history                |

---

## Resolved Design Choices

1. **MAS source:** Latest time trial by default; coach can set override via `athlete_mas_overrides` (e.g. post-injury). Override is visible in UI and does not create a time trial record.
2. **Session outputs:** Stored in `session_history` + `session_group_outputs` for full history. Favourites saved as `session_templates`.
3. **Shuttle logic:** `(distance - 2) / 2` — subtract 2 m (change of direction cost), then halve.

---

## Next Steps

1. Create Supabase project and run migrations for these tables.
2. Set up RLS policies.
3. Add database functions/triggers if needed (e.g. auto-compute MAS).
4. Build Next.js app with Supabase client.
