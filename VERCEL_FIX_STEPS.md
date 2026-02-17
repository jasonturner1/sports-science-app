# Fix 404 – Production is on an old commit

## What’s wrong

- **Production is built from commit `b2de2b3`.**
- That build only has routes: `/` and `/_not-found`. No `/auth`, no redirects.
- Your newer commits (`98c6df6`, `7fd981c`) have the auth page and redirects, but **production is not using them**.

So we need production to use the **latest** commit on `main`.

---

## Step 1: Check the latest commit on `main` (GitHub)

1. Open: **https://github.com/jasonturner1/sports-science-app**
2. Make sure the branch is **main** (dropdown at the top left).
3. Look at the **latest commit** at the top of the file list (message + hash).

- If the **latest commit** is **b2de2b3**: the auth and redirects are **not** on `main`. Go to **Step 2**.
- If the **latest commit** is **98c6df6** or **7fd981c** (or newer): the code is on `main`. Go to **Step 3**.

---

## Step 2: If the latest on `main` is still b2de2b3

Then the commits with auth/redirects are only on another branch or only in your uploads to a different branch. You need that code on `main`:

**Option A – Same repo, main branch**

1. On GitHub, switch to **main**.
2. Re-upload or re-commit the same files that have:
   - `src/app/auth/page.tsx`
   - `next.config.ts` with redirects
   - `src/app/page.tsx` with `href="/auth"` and `href="/auth?mode=signup"`
3. Commit on **main**. That creates a **new** commit (e.g. `abc1234`).

**Option B – You see a branch like “patch-1” or “vercel” with the new code**

1. Open that branch on GitHub.
2. Click **Pull requests** → **New pull request**.
3. Base: **main**, Compare: **your branch**.
4. Create the PR and **Merge** it into `main`.

After Step 2, **main** should have a commit **newer** than b2de2b3 (with auth + redirects). Then do **Step 3**.

---

## Step 3: Trigger a new production deployment from latest `main`

1. Go to **Vercel** → your project → **Deployments**.
2. Look at the list. Find the **top** deployment (most recent).
3. Check its **commit hash**:
   - If it’s **b2de2b3**: that’s the old one. We need a new deploy from the latest commit on `main`.
   - If it’s **98c6df6** or **7fd981c** (or your new commit from Step 2): that’s the right code.

**If the latest deployment (top of list) has the new commit but is “Preview”:**

- Click that deployment.
- Click the **⋮** (three dots) menu.
- Choose **“Promote to Production”** (or “Assign to Production”).
- That makes this build the one used for `sports-science-app.vercel.app`.

**If the latest deployment is still b2de2b3:**

- Then **main** on GitHub hasn’t been updated, or Vercel didn’t run a new build for `main`.
- Push or merge so **main** has a new commit (see Step 2), then wait for Vercel to auto-deploy, or:
- In Vercel: **Deployments** → **“Redeploy”** or **“Deploy”** and choose branch **main** so it builds from the latest commit on `main`.

---

## Step 4: Update Next.js version on GitHub

So the build stops using 15.0.5:

1. On GitHub, open **package.json**.
2. Change **"next": "15.0.5"** to **"next": "15.0.7"**.
3. Change **"eslint-config-next": "15.0.5"** to **"eslint-config-next": "15.0.7"**.
4. Commit on **main**.

Then trigger a new production deployment (Step 3) so the new build uses 15.0.7.

---

## After this

- Production will be built from a commit that includes `src/app/auth/page.tsx` and the redirects.
- The build output should show something like: **Route (app) … /auth** (and still `/`).
- **https://sports-science-app.vercel.app/** → Sign in → should go to **/auth** (or **/login** should redirect to **/auth**).

---

## Summary

| What you want | How |
|---------------|-----|
| Production to use auth + redirects | Production must be built from a commit that has `src/app/auth/` and `next.config` redirects. |
| That to happen | Latest code must be on **main**, then production deployment must be from that latest commit (new deploy or “Promote to Production”). |
| No more 15.0.5 warning | Set Next to 15.0.7 in **package.json** on **main** and redeploy. |
