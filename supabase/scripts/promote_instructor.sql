-- Promote a user to instructor by email

UPDATE profiles
SET
    role = 'instructor',
    status = 'active',
    updated_at = NOW()
WHERE email = 'instructor@yourcenter.com';

SELECT id, email, full_name, role, status FROM profiles WHERE role = 'instructor';
