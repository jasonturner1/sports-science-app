# Connect Cursor to GitHub (Push from Cursor)

Cursor uses **Git** to push to GitHub. You need Git available for Cursor to do this.

---

## Option A: Install Git (if you have admin rights)

1. Download Git: [git-scm.com/download/win](https://git-scm.com/download/win)
2. Run the installer → use default options
3. **Restart Cursor** after installing
4. Skip to "Connect Your Repo" below

---

## Option B: Portable Git (no admin required)

1. Go to [Git for Windows releases](https://github.com/git-for-windows/git/releases/latest)
2. Download **`PortableGit-*-64-bit.7z.exe`** (or the .zip if available)
3. Extract to a folder you can write to, e.g. `C:\Users\jturner\GitPortable`
4. In Cursor, open Settings (Ctrl+,) → search **"git path"**
5. Set **Git: Path** to: `C:\Users\jturner\GitPortable\cmd\git.exe`  
   (adjust if you extracted elsewhere)
6. Restart Cursor

---

## Connect Your Repo

### 1. Initialize Git (if not already)

- Open Cursor's **Source Control** panel (Ctrl+Shift+G)
- If you see "Initialize Repository", click it
- If you already have a repo, skip this

### 2. Add GitHub as remote

- Open the **Command Palette** (Ctrl+Shift+P)
- Type **"Git: Add Remote"**
- Remote name: `origin`
- URL: `https://github.com/jasonturner1/sports-science-app.git`

### 3. Sign in to GitHub (first time only)

- In Source Control, when you try to push, Cursor will prompt you to sign in
- Or: **Command Palette** → **"GitHub: Sign In"**
- Sign in via browser when prompted

### 4. Commit and push

1. In Source Control, stage your changes (click + next to files, or "Stage All")
2. Enter a commit message (e.g. "Fix dependencies and RLS")
3. Click the **✓ Commit** button
4. Click the **⋯** menu → **Push** (or the sync icon)

---

## After setup

Once Git is working, you can say things like:

- *"Push these changes to GitHub"*
- *"Commit and push"*
- *"Push to main"*

And Cursor (or the AI) can run the git commands for you.
