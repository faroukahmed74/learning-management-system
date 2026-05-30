-- Dev bootstrap: confirm emails + set roles
-- Run in Supabase SQL Editor after users have registered in the app.
-- Edit the emails below to match your accounts.

-- 1) Confirm email so login works (dev shortcut — or disable Confirm email in Auth settings)
-- Note: confirmed_at is a generated column — only set email_confirmed_at.
UPDATE auth.users
SET email_confirmed_at = COALESCE(email_confirmed_at, NOW())
WHERE email IN (
  'faroukahmed192@gmail.com',
  'mido24687886@gmail.com'
);

-- 2) Promote admin (pick ONE primary admin email)
UPDATE profiles
SET role = 'admin', status = 'active', updated_at = NOW()
WHERE email = 'faroukahmed192@gmail.com';

-- 3) Optional: promote instructor (register this account in the app first)
-- UPDATE profiles
-- SET role = 'instructor', status = 'active', updated_at = NOW()
-- WHERE email = 'instructor@yourcenter.com';

-- 4) Verify
SELECT u.email, u.email_confirmed_at IS NOT NULL AS email_confirmed, p.role, p.status
FROM auth.users u
LEFT JOIN profiles p ON p.id = u.id
WHERE u.email IN (
  'faroukahmed192@gmail.com',
  'mido24687886@gmail.com'
)
ORDER BY u.email;
