# Admin User Bootstrap — Step 3

## Quick setup (recommended)

### 1. Register or create a user

**Option A — Via the app**

1. Run the app: `flutter run -d chrome`
2. Click **Create student account**
3. Register with your admin email (e.g. `admin@yourcenter.com`)

**Option B — Via Supabase Dashboard**

1. Go to **Authentication** → **Users** → **Add user**
2. Enter email + password, check **Auto Confirm User**

### 2. Promote to admin

In **SQL Editor**, run:

```sql
-- Replace with your admin email
UPDATE profiles
SET role = 'admin', status = 'active'
WHERE email = 'admin@yourcenter.com';
```

Or use the script: `supabase/scripts/promote_admin.sql`

### 3. Create an instructor (optional)

```sql
UPDATE profiles
SET role = 'instructor', status = 'active'
WHERE email = 'instructor@yourcenter.com';
```

### 4. Seed default center (optional)

Run `supabase/seed.sql` in SQL Editor to create a default language center.

### 5. Verify

1. Sign out and sign in again as admin
2. You should land on **Admin Dashboard**
3. Admin can access all instructor and student routes

## Create users via SQL (advanced)

```sql
-- After creating user in Auth dashboard, get their UUID from Authentication → Users
UPDATE profiles
SET
  role = 'instructor',
  status = 'active',
  full_name = 'Jane Instructor',
  native_language = 'English',
  target_language = 'French'
WHERE id = 'USER-UUID-HERE';
```

## Role reference

| Role | Home route |
|------|------------|
| `admin` | `/admin/dashboard` |
| `instructor` | `/instructor/dashboard` |
| `student` | `/student/dashboard` |
