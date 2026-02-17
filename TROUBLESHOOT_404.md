# Fix 404 – Screenshot checklist

Please send **one screenshot per step** in order. That will show where things are going wrong.

---

## Screenshot 1: GitHub – what’s inside `src/app`

1. Open: **https://github.com/jasonturner1/sports-science-app**
2. Click the **`src`** folder.
3. Click the **`app`** folder.
4. **Screenshot:** the list of items inside `app` (you should see `auth`, `login`, `signup`, `layout.tsx`, `page.tsx`, `globals.css`).

**Why:** We need to see if `auth` exists and that you’re in the right repo path.

---

## Screenshot 2: GitHub – `src/app/auth` has a page

1. Still in **`src/app`**, click the **`auth`** folder.
2. **Screenshot:** the contents of `auth` (you should see **`page.tsx`**).

**Why:** If `auth/page.tsx` is missing, `/auth` will 404.

---

## Screenshot 3: GitHub – home page links

1. Go to **https://github.com/jasonturner1/sports-science-app**
2. Open **`src/app/page.tsx`** (click it).
3. **Screenshot:** the file content, especially the two `Link` lines (the ones with `href=...`).

**Why:** If they still say `href="/login"` and `href="/signup"`, the live site will send you to `/login` and 404. They should say `href="/auth"` and `href="/auth?mode=signup"`.

---

## Screenshot 4: GitHub – redirects in config

1. In the repo root, open **`next.config.ts`**.
2. **Screenshot:** the full file content.

**Why:** We need to see if the `/login` → `/auth` and `/signup` → `/auth?mode=signup` redirects are there. If not, old links to `/login` will 404.

---

## Screenshot 5: Vercel – production deployment

1. Go to **https://vercel.com** → your project **sports-science-app**.
2. Open the **Deployments** tab.
3. Find the deployment that has the **Production** badge (or the one linked to your main domain).
4. **Screenshot:** that row so we can see:
   - **Commit message**
   - **Branch** (e.g. `main`)
   - **Commit hash** (e.g. `98c6df6`)
   - **Status** (e.g. Ready)
   - **Time** (e.g. “2 hours ago”).

**Why:** We need to confirm production is built from the same commit that has the auth page and redirects.

---

## Screenshot 6: Vercel – Root Directory

1. In your project, go to **Settings** → **General**.
2. Scroll to **Root Directory**.
3. **Screenshot:** that section (the input and any text next to it).

**Why:** If Root Directory is set (e.g. to `Project` or `src`), the build may not see `src/app` correctly and routes can 404. It should be **empty** or **.** for this repo.

---

## Screenshot 7: Vercel – build log (route list)

1. **Deployments** → click the **latest production** deployment.
2. Open the **Building** log (or the tab that shows the build output).
3. Scroll to where it runs **`next build`** and look for a list of **routes** or **pages** (e.g. “Route (app) …” or “○ / …” or “ƒ /auth”).
4. **Screenshot:** the part of the log that lists routes/pages.

**Why:** If `/auth` (or `/login`/`/signup`) never appears in the build output, that route wasn’t built and will 404.

---

## Screenshot 8: Browser – what happens when you click Sign in

1. Open **https://sports-science-app.vercel.app/**
2. Click **Sign in**.
3. **Screenshot:** the **full browser window** after the click, including:
   - The **address bar** (exact URL, e.g. `.../login` or `.../auth`).
   - The **page content** (e.g. 404 message or the sign-in form).

**Why:** This shows whether you’re sent to `/login` (old link) or `/auth`, and whether the result is 404 or the auth page.

---

## After you send the screenshots

I’ll tell you exactly what’s wrong and what to change (e.g. “update this file on GitHub” or “clear Root Directory on Vercel” or “redeploy from this branch”).

**Order:** 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8. You can paste the screenshots in one message and label them (e.g. “Screenshot 1”, “Screenshot 2”, …).
