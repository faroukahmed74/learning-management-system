# Supabase Setup Guide — Step 1

Follow these steps to connect the LMS to your Supabase backend.

## 1. Create a Supabase project

1. Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Click **New project**
3. Choose organization, name (e.g. `language-center-lms`), database password, region
4. Wait for the project to finish provisioning (~2 minutes)

## 2. Get API credentials

1. Open your project → **Project Settings** → **API**
2. Copy:
   - **Project URL** → `SUPABASE_URL`
   - **anon public** key → `SUPABASE_ANON_KEY`

## 3. Configure the Flutter app

```bash
cp .env.example .env
```

Edit `.env`:

```env
SUPABASE_URL=https://xxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Restart the app after changing `.env`.

## 4. Run database migrations (Step 2)

**Option A — Supabase Dashboard (easiest)**

1. Go to **SQL Editor** → **New query**
2. Run each migration file in order:
   - `supabase/migrations/20260523000000_initial_schema.sql`
   - `supabase/migrations/20260523000001_rls_storage.sql`
3. Click **Run** for each file

**Option B — Supabase CLI**

```bash
# Install CLI: https://supabase.com/docs/guides/cli
brew install supabase/tap/supabase

supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase db push
```

## 5. Verify connection

Run the app and sign in. The login screen shows a green **Connected to Supabase** banner when configured correctly.

Or run:

```bash
dart run tool/verify_supabase.dart
```

## 6. Create admin user (Step 3)

See [docs/06_ADMIN_BOOTSTRAP.md](06_ADMIN_BOOTSTRAP.md).

## 7. Auth email settings (recommended)

In Supabase Dashboard → **Authentication** → **Providers** → **Email**:

- Enable email provider
- For development: disable **Confirm email** (re-enable for production)
- Set **Site URL** to your app URL (e.g. `http://localhost:3000` for web dev)

## 8. Storage buckets

Migration `20260523000001` creates buckets automatically. Verify under **Storage**:

| Bucket | Access |
|--------|--------|
| `avatars` | Public read |
| `course-thumbnails` | Public read |
| `materials` | Private (signed URLs) |

## Troubleshooting

| Issue | Fix |
|-------|-----|
| "Supabase not configured" | Check `.env` values, restart app |
| Login fails with RLS error | Run both migration files |
| Profile not created on signup | Check `handle_new_user` trigger exists |
| Upload fails | Verify storage buckets and policies |
