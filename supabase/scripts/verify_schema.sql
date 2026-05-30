-- Full schema verification — run in Supabase SQL Editor
-- Expected: all checks return rows; "missing_*" queries should return 0 rows

-- ========== 1) ENUM TYPES (8) ==========
SELECT typname AS enum_type
FROM pg_type t
JOIN pg_namespace n ON n.oid = t.typnamespace
WHERE n.nspname = 'public'
  AND t.typtype = 'e'
  AND typname IN (
    'user_role', 'profile_status', 'cefr_level', 'course_status',
    'lesson_type', 'material_type', 'enrollment_status', 'progress_status'
  )
ORDER BY typname;
-- Expected: 8 rows

-- ========== 2) TABLES (12) ==========
SELECT tablename
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'centers', 'profiles', 'courses', 'course_modules', 'lessons',
    'lesson_materials', 'batches', 'enrollments', 'lesson_progress',
    'live_sessions', 'notifications', 'audit_logs'
  )
ORDER BY tablename;
-- Expected: 12 rows

-- Missing tables (should return 0 rows)
SELECT expected AS missing_table
FROM unnest(ARRAY[
  'centers', 'profiles', 'courses', 'course_modules', 'lessons',
  'lesson_materials', 'batches', 'enrollments', 'lesson_progress',
  'live_sessions', 'notifications', 'audit_logs'
]) AS expected
WHERE expected NOT IN (
  SELECT tablename FROM pg_tables WHERE schemaname = 'public'
);

-- ========== 3) VIEWS (1) ==========
SELECT viewname FROM pg_views
WHERE schemaname = 'public' AND viewname = 'admin_dashboard_stats';

-- ========== 4) KEY FUNCTIONS (7) ==========
SELECT proname AS function_name
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public'
  AND proname IN (
    'is_admin', 'is_instructor', 'is_enrolled_in_course',
    'set_updated_at', 'check_lesson_completion',
    'handle_new_user', 'notify_on_enrollment'
  )
ORDER BY proname;
-- Expected: 7 rows

-- ========== 5) TRIGGERS (12+) ==========
SELECT tgname AS trigger_name, relname AS table_name
FROM pg_trigger t
JOIN pg_class c ON c.oid = t.tgrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE NOT t.tgisinternal
  AND n.nspname IN ('public', 'auth')
  AND tgname IN (
    'on_auth_user_created',
    'trg_centers_updated', 'trg_profiles_updated', 'trg_courses_updated',
    'trg_modules_updated', 'trg_lessons_updated', 'trg_materials_updated',
    'trg_batches_updated', 'trg_enrollments_updated', 'trg_progress_updated',
    'trg_lesson_progress_completion', 'trg_notify_enrollment'
  )
ORDER BY tgname;
-- Expected: 12 rows

-- ========== 6) RLS ENABLED ==========
SELECT relname AS table_name, relrowsecurity AS rls_enabled
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND relkind = 'r'
  AND relname IN (
    'centers', 'profiles', 'courses', 'course_modules', 'lessons',
    'lesson_materials', 'batches', 'enrollments', 'lesson_progress',
    'live_sessions', 'notifications', 'audit_logs'
  )
ORDER BY relname;
-- Expected: all rls_enabled = true

-- ========== 7) STORAGE BUCKETS (3) ==========
SELECT id, name, public, file_size_limit
FROM storage.buckets
WHERE id IN ('avatars', 'course-thumbnails', 'materials')
ORDER BY id;
-- Expected: 3 rows

-- ========== 8) SEED DATA ==========
SELECT id, name, slug, is_active FROM centers WHERE slug = 'main-center';

-- ========== 9) GRANTS (mvp migration) ==========
SELECT grantee, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND table_name = 'admin_dashboard_stats'
  AND grantee = 'authenticated';

-- ========== 10) COLUMN SPOT-CHECK (profiles linked to auth) ==========
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'profiles'
ORDER BY ordinal_position;
