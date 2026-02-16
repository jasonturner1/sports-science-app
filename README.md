# Sports Science App

MVP for managing athlete time trial data, squads, groups, and training sessions. Built with Next.js 15 and Supabase.

## Prerequisites

- Node.js 18+
- A [Supabase](https://supabase.com) project

## Setup

### 1. Install dependencies

```bash
npm install
```

### 2. Configure Supabase

1. Create a project at [supabase.com](https://supabase.com)
2. Copy `.env.local.example` to `.env.local`
3. Add your Supabase URL and anon key from **Project Settings → API**:

```
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

### 3. Run database migrations

In the Supabase Dashboard, go to **SQL Editor** and run the migrations in order:

1. `supabase/migrations/20250217000001_initial_schema.sql`
2. `supabase/migrations/20250217000002_rls_policies.sql`
3. `supabase/migrations/20250217000003_auth_trigger.sql`

Or, if you have the [Supabase CLI](https://supabase.com/docs/guides/cli) installed and linked:

```bash
supabase db push
```

### 4. Enable Email auth (optional)

In Supabase Dashboard → **Authentication → Providers**, enable Email. Configure redirect URLs under **URL Configuration** if using custom domains.

### 5. Run the app

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

## Project structure

```
src/
├── app/              # Next.js App Router pages
├── lib/
│   ├── supabase/     # Supabase client (browser, server, middleware)
│   ├── types/        # TypeScript types
│   └── utils/        # MAS calculation helpers
supabase/
└── migrations/       # SQL migrations
```

## Database schema

See `DATABASE_PLAN.md` for the full schema and data flow.

## Deploy to Vercel (no Node.js required)

See **[DEPLOYMENT.md](./DEPLOYMENT.md)** for step-by-step instructions to push to GitHub and deploy on Vercel using only your browser.

## Next steps

- Add login/signup pages
- Build coach dashboard (squads, athletes, time trials)
- Build session builder with variables and group output
- Add athlete portal for viewing assigned sessions
