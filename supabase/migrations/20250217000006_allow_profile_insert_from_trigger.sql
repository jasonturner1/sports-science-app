-- Allow profile insert from trigger (trigger runs in context that can see auth.users)
-- Replaces policy that used auth.uid() (null when trigger runs)
DROP POLICY IF EXISTS "Allow insert own profile on signup" ON profiles;

CREATE POLICY "Allow insert profile when id in auth.users"
  ON profiles FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM auth.users u WHERE u.id = profiles.id)
  );
