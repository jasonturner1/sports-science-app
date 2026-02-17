# Fix 404 and Next.js version – exact GitHub steps

Your Vercel build is still using **next@15.0.5** and the **login/signup** routes may be missing or in the wrong structure. Do these three things on GitHub.

---

## 1. Update `package.json` (fix security warning)

- On GitHub, open **package.json** → click the **pencil (Edit)** icon.
- Find the two lines with `15.0.5` and change both to **15.0.7**:
  - `"next": "15.0.7",`
  - `"eslint-config-next": "15.0.7",`
- Click **Commit changes**.

---

## 2. Add the single auth page (fixes 404)

We now use **one** auth page: **/auth** (sign in) and **/auth?mode=signup** (sign up).

- On GitHub, click **Add file** → **Create new file**.
- In the name box, type exactly: **src/app/auth/page.tsx**  
  (GitHub will create the `src/app/auth` folders for you.)
- Open your local file **src/app/auth/page.tsx** in Cursor, copy **all** of its content, and paste it into the GitHub editor.
- Click **Commit new file**.

---

## 3. Update the home page links

- On GitHub, open **src/app/page.tsx** → **Edit**.
- Change the two links so they are:
  - **Sign in** → `href="/auth"`
  - **Sign up** → `href="/auth?mode=signup"`
- Click **Commit changes**.

---

## 4. Redeploy on Vercel

- Vercel → your project → **Deployments** → **⋯** on the latest → **Redeploy** (without cache if possible).

After this, **https://your-app.vercel.app/auth** should load (sign in), and **/auth?mode=signup** should show sign up. The Next.js security warning should be gone.
