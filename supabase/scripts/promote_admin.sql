-- Promote a user to admin by email
-- Usage: Replace the email below, then run in Supabase SQL Editor

UPDATE profiles
SET
    role = 'admin',
    status = 'active',
    updated_at = NOW()
WHERE email = 'admin@yourcenter.com';

-- Verify
SELECT id, email, full_name, role, status FROM profiles WHERE role = 'admin';
