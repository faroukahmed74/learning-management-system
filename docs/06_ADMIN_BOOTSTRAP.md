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

**Option A — SQL Editor (no extra keys)**

Run `supabase/scripts/bootstrap_dev.sql` in **SQL Editor** (edit emails first).

Or run:

```sql
UPDATE profiles
SET role = 'admin', status = 'active'
WHERE email = 'admin@yourcenter.com';
```

**Option B — CLI script (automated)**

1. Add `SUPABASE_SERVICE_ROLE_KEY` to `.env` (Dashboard → Settings → API)
2. Run:

```bash
chmod +x tool/bootstrap_roles.sh
./tool/bootstrap_roles.sh admin@yourcenter.com instructor@yourcenter.com
```

### 3. Email not confirmed?

- Use **Resend verification email** on the login screen, or
- Run the confirm block in `bootstrap_dev.sql`, or
- Disable **Confirm email** under **Authentication → Providers → Email** (dev only)

### 4. Create an instructor (optional)

```sql
UPDATE profiles
SET role = 'instructor', status = 'active'
WHERE email = 'instructor@yourcenter.com';
```

### 5. Seed default center (optional)

Run `supabase/seed.sql` in SQL Editor to create a default language center.

### 6. Verify

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
