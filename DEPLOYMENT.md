# Deploy to GitHub + Vercel (No Node or Git Required)

Follow these steps to get your Sports Science App live. You can do everything from your browser.

---

## Part 1: Push to GitHub

### Step 1.1 — Create a GitHub account
If you don't have one: go to [github.com](https://github.com) and sign up (free).

### Step 1.2 — Create a new repository
1. Click the **+** in the top-right → **New repository**
2. Name it: `sports-science-app` (or any name)
3. Choose **Public**
4. **Do not** check "Add a README" or "Add .gitignore"
5. Click **Create repository**

### Step 1.3 — Upload your project files
1. On the new repo page, click **"uploading an existing file"** (or the **Add file** dropdown → **Upload files**)
2. Open your project folder: `c:\Users\jturner\OneDrive - De La Salle College\Desktop\Project`
3. **Important:** Upload the *contents* of the folder (not the folder itself). Select:
   - `src` folder
   - `supabase` folder
   - `package.json`, `next.config.ts`, `tsconfig.json`, `tailwind.config.ts`, `postcss.config.mjs`, `vercel.json`
   - `eslint.config.mjs`, `.gitignore`, `README.md`, `DATABASE_PLAN.md`, `DEPLOYMENT.md`
4. Drag them into the GitHub upload area, or use **Choose your files**
5. In the commit message box, type: `Initial commit`
6. Click **Commit changes**

**Files to include:**
- `src/` folder (with all contents)
- `supabase/` folder (with all contents)
- `package.json`, `next.config.ts`, `tsconfig.json`, `tailwind.config.ts`, `postcss.config.mjs`, `vercel.json`
- `eslint.config.mjs`, `.gitignore`, `README.md`, `DATABASE_PLAN.md`, `DEPLOYMENT.md`

**Do NOT upload:**
- `node_modules/` (if present — it's in .gitignore)
- `.env.local` (contains secrets — never upload)

---

## Part 2: Deploy to Vercel

### Step 2.1 — Sign up for Vercel
1. Go to [vercel.com](https://vercel.com)
2. Click **Sign Up** → **Continue with GitHub**
3. Authorize Vercel to access your GitHub account

### Step 2.2 — Import your project
1. On the Vercel dashboard, click **Add New** → **Project**
2. Find `sports-science-app` in the list and click **Import**
3. Vercel will detect Next.js automatically — no changes needed
4. Before deploying, click **Environment Variables** and add:

   | Name | Value |
   |------|-------|
   | `NEXT_PUBLIC_SUPABASE_URL` | Your Supabase project URL (from Supabase Dashboard → Settings → API) |
   | `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Your Supabase anon key (from same page) |

5. Click **Deploy**

### Step 2.3 — Wait for the build
- Build usually takes 1–2 minutes
- When it finishes, you'll get a live URL like `sports-science-app.vercel.app`

---

## Part 3: Configure Supabase for your live URL

1. In [Supabase Dashboard](https://supabase.com/dashboard) → **Authentication** → **URL Configuration**
2. Add your Vercel URL to **Redirect URLs**:  
   `https://your-project.vercel.app/**`  
   (Replace with your actual Vercel URL)
3. Add the same to **Site URL** if you want it as the main URL

---

## Updating your app later

1. Edit files locally in Cursor
2. Go to your GitHub repo → **Add file** → **Upload files**
3. Upload the changed files (overwrite existing)
4. Commit
5. Vercel will automatically redeploy when it detects the new commit

---

## Troubleshooting

**Build fails on Vercel**
- Check the build logs for the error
- Ensure all files were uploaded (especially `package.json`, `next.config.ts`)

**"Supabase URL not found" or auth errors**
- Add `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` in Vercel → Project → Settings → Environment Variables
- Redeploy after adding variables

**Database not working**
- Run the Supabase migrations in the SQL Editor (see README) if you haven't already
