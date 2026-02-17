# Fix 404 + Auto-Deploy on Every Change

## Why you still get 404

The `/login` and `/signup` pages exist in your **local** project but are only live after they’re on **GitHub** and Vercel has deployed that code.

- On **GitHub**, check that these paths exist in your repo:
  - `src/app/login/page.tsx`
  - `src/app/signup/page.tsx`
- If they’re missing, the site will 404 on `/login` and `/signup`.

**Fix now:** Upload your **entire `src` folder** again (Add file → Upload files → drag the `src` folder). That will add or update `src/app/login/` and `src/app/signup/`. Then in Vercel, trigger a new deployment (Deployments → ⋯ → Redeploy) so the new build runs.

---

## Auto-deploy: push from Cursor → GitHub → Vercel

Once this is set up, **every time you push to GitHub, Vercel will deploy automatically.** No manual uploads.

### 1. Install Git

- Download: [git-scm.com/download/win](https://git-scm.com/download/win)
- Run the installer (defaults are fine)
- **Restart Cursor** after installing

### 2. Connect your project to GitHub in Cursor

1. In Cursor, open **Source Control** (Ctrl+Shift+G).
2. If you see **“Initialize Repository”**, click it.
3. **Command Palette** (Ctrl+Shift+P) → run **“Git: Add Remote”**.
   - Name: `origin`
   - URL: `https://github.com/jasonturner1/sports-science-app.git`
4. When you push the first time, sign in to GitHub in the browser if asked.

### 3. First push (get GitHub in sync)

1. In Source Control, click **“Stage All”** (or stage the files you changed).
2. Commit message: e.g. `Add login and signup pages`.
3. Click **✓ Commit**.
4. Open the **⋯** menu in Source Control → **Push** (or use the sync icon). If it asks for a branch, choose `main` and confirm.

Your repo on GitHub will match your local project, and Vercel will run a new deployment.

### 4. After that: every change → deploy

1. Edit code in Cursor.
2. **Source Control** → Stage your changes → **Commit** → **Push**.
3. Vercel will detect the push and deploy. No manual upload or “Redeploy” needed.

---

## If you can’t install Git

Keep using **Upload files** on GitHub:

1. After you change code, open the repo on GitHub.
2. **Add file** → **Upload files**.
3. Upload the **changed files or folders** (e.g. the whole `src` folder if you added login/signup).
4. Commit. Vercel will deploy from the new commit.

To avoid 404, make sure **`src/app/login/page.tsx`** and **`src/app/signup/page.tsx`** are in the repo (inside `src/app/login/` and `src/app/signup/`).
