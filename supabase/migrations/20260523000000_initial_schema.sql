-- LMS MVP initial schema
-- Run via Supabase CLI: supabase db push

CREATE TYPE user_role AS ENUM ('admin', 'instructor', 'student');
CREATE TYPE profile_status AS ENUM ('active', 'suspended', 'pending_verification');
CREATE TYPE cefr_level AS ENUM ('A1', 'A2', 'B1', 'B2', 'C1', 'C2');
CREATE TYPE course_status AS ENUM ('draft', 'published', 'archived');
CREATE TYPE lesson_type AS ENUM ('video', 'document', 'mixed', 'live_link');
CREATE TYPE material_type AS ENUM ('video', 'document', 'audio', 'image', 'link');
CREATE TYPE enrollment_status AS ENUM ('active', 'completed', 'dropped', 'suspended');
CREATE TYPE progress_status AS ENUM ('not_started', 'in_progress', 'completed');

CREATE TABLE centers (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        TEXT NOT NULL,
    slug        TEXT NOT NULL UNIQUE,
    address     TEXT,
    phone       TEXT,
    email       TEXT,
    timezone    TEXT NOT NULL DEFAULT 'UTC',
    logo_url    TEXT,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE profiles (
    id              UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role            user_role NOT NULL DEFAULT 'student',
    full_name       TEXT NOT NULL,
    email           TEXT NOT NULL,
    phone           TEXT,
    avatar_url      TEXT,
    bio             TEXT,
    center_id       UUID REFERENCES centers(id) ON DELETE SET NULL,
    native_language TEXT,
    target_language TEXT,
    level           cefr_level,
    date_of_birth   DATE,
    status          profile_status NOT NULL DEFAULT 'pending_verification',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_center ON profiles(center_id);
CREATE UNIQUE INDEX idx_profiles_email_unique ON profiles(LOWER(email));

CREATE TABLE courses (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title           TEXT NOT NULL CHECK (char_length(title) BETWEEN 3 AND 120),
    slug            TEXT NOT NULL UNIQUE,
    description     TEXT,
    language_taught TEXT NOT NULL,
    level           cefr_level NOT NULL,
    thumbnail_url   TEXT,
    instructor_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    center_id       UUID REFERENCES centers(id) ON DELETE SET NULL,
    status          course_status NOT NULL DEFAULT 'draft',
    price           DECIMAL(10,2) DEFAULT 0,
    duration_weeks  INT,
    max_students    INT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    published_at    TIMESTAMPTZ
);

CREATE INDEX idx_courses_instructor ON courses(instructor_id);
CREATE INDEX idx_courses_status ON courses(status);

CREATE TABLE course_modules (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id   UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title       TEXT NOT NULL,
    description TEXT,
    sort_order  INT NOT NULL DEFAULT 0,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (course_id, sort_order)
);

CREATE TABLE lessons (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id        UUID NOT NULL REFERENCES course_modules(id) ON DELETE CASCADE,
    title            TEXT NOT NULL,
    description      TEXT,
    type             lesson_type NOT NULL DEFAULT 'mixed',
    sort_order       INT NOT NULL DEFAULT 0,
    duration_minutes INT,
    is_free_preview  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (module_id, sort_order)
);

CREATE TABLE lesson_materials (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id           UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    type                material_type NOT NULL,
    title               TEXT NOT NULL,
    storage_path        TEXT,
    external_url        TEXT,
    file_name           TEXT,
    mime_type           TEXT,
    file_size_bytes     BIGINT,
    duration_seconds    INT,
    thumbnail_url       TEXT,
    sort_order          INT NOT NULL DEFAULT 0,
    is_downloadable     BOOLEAN NOT NULL DEFAULT TRUE,
    transcoding_status  TEXT DEFAULT 'ready',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE batches (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id       UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    instructor_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    center_id       UUID REFERENCES centers(id) ON DELETE SET NULL,
    name            TEXT NOT NULL,
    start_date      DATE,
    end_date        DATE,
    schedule        JSONB,
    max_students    INT,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE enrollments (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id  UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    course_id   UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    batch_id    UUID REFERENCES batches(id) ON DELETE SET NULL,
    status      enrollment_status NOT NULL DEFAULT 'active',
    enrolled_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    dropped_at  TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (student_id, course_id)
);

CREATE TABLE lesson_progress (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id              UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    lesson_id               UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    status                  progress_status NOT NULL DEFAULT 'not_started',
    video_position_seconds  INT NOT NULL DEFAULT 0,
    completion_percentage   SMALLINT NOT NULL DEFAULT 0 CHECK (completion_percentage BETWEEN 0 AND 100),
    started_at              TIMESTAMPTZ,
    completed_at            TIMESTAMPTZ,
    last_accessed_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (student_id, lesson_id)
);

CREATE TABLE live_sessions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id       UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    batch_id        UUID REFERENCES batches(id) ON DELETE SET NULL,
    instructor_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    title           TEXT NOT NULL,
    description     TEXT,
    start_time      TIMESTAMPTZ NOT NULL,
    end_time        TIMESTAMPTZ NOT NULL,
    meeting_url     TEXT NOT NULL,
    recording_url   TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE notifications (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    title       TEXT NOT NULL,
    body        TEXT,
    type        TEXT NOT NULL DEFAULT 'general',
    data        JSONB,
    is_read     BOOLEAN NOT NULL DEFAULT FALSE,
    read_at     TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE audit_logs (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id    UUID REFERENCES profiles(id) ON DELETE SET NULL,
    action      TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id   UUID,
    metadata    JSONB,
    ip_address  INET,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO profiles (id, email, full_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'student')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY profiles_select_own ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY profiles_update_own ON profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY courses_select_published ON courses
    FOR SELECT USING (status = 'published');

CREATE POLICY enrollments_select_student ON enrollments
    FOR SELECT USING (student_id = auth.uid());

CREATE POLICY progress_student_own ON lesson_progress
    FOR ALL USING (student_id = auth.uid());
