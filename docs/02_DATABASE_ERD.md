# Database ERD & PostgreSQL Table Design

**Version:** 1.0  
**Database:** PostgreSQL 15+ (Supabase)  
**Last updated:** 2026-05-23

---

## 1. Entity Relationship Diagram

```mermaid
erDiagram
    auth_users ||--o| profiles : has
    centers ||--o{ profiles : employs
    centers ||--o{ courses : offers
    profiles ||--o{ courses : instructs
    courses ||--o{ course_modules : contains
    course_modules ||--o{ lessons : contains
    lessons ||--o{ lesson_materials : has
    courses ||--o{ batches : schedules
    profiles ||--o{ batches : teaches
    batches ||--o{ batch_enrollments : includes
    courses ||--o{ enrollments : has
    profiles ||--o{ enrollments : enrolled_as
    profiles ||--o{ lesson_progress : tracks
    lessons ||--o{ lesson_progress : tracked_in
    courses ||--o{ live_sessions : hosts
    batches ||--o{ live_sessions : hosts
    profiles ||--o{ notifications : receives
    profiles ||--o{ audit_logs : performs

    auth_users {
        uuid id PK
        string email
        timestamptz created_at
    }

    profiles {
        uuid id PK_FK
        user_role role
        string full_name
        string phone
        string avatar_url
        uuid center_id FK
        string native_language
        string target_language
        cefr_level level
        profile_status status
    }

    centers {
        uuid id PK
        string name
        string address
        string timezone
        boolean is_active
    }

    courses {
        uuid id PK
        string title
        string slug UK
        uuid instructor_id FK
        uuid center_id FK
        language_code language_taught
        cefr_level level
        course_status status
    }

    course_modules {
        uuid id PK
        uuid course_id FK
        string title
        int sort_order
    }

    lessons {
        uuid id PK
        uuid module_id FK
        string title
        lesson_type type
        int sort_order
        boolean is_free_preview
    }

    lesson_materials {
        uuid id PK
        uuid lesson_id FK
        material_type type
        string storage_path
        string file_name
        bigint file_size_bytes
        int duration_seconds
    }

    batches {
        uuid id PK
        uuid course_id FK
        uuid instructor_id FK
        string name
        date start_date
        date end_date
    }

    enrollments {
        uuid id PK
        uuid student_id FK
        uuid course_id FK
        uuid batch_id FK
        enrollment_status status
    }

    lesson_progress {
        uuid id PK
        uuid student_id FK
        uuid lesson_id FK
        progress_status status
        int video_position_seconds
    }

    live_sessions {
        uuid id PK
        uuid course_id FK
        uuid batch_id FK
        timestamptz start_time
        string meeting_url
    }

    notifications {
        uuid id PK
        uuid user_id FK
        string title
        boolean is_read
    }

    audit_logs {
        uuid id PK
        uuid actor_id FK
        string action
        jsonb metadata
    }
```

---

## 2. Enums

```sql
CREATE TYPE user_role AS ENUM ('admin', 'instructor', 'student');

CREATE TYPE profile_status AS ENUM ('active', 'suspended', 'pending_verification');

CREATE TYPE cefr_level AS ENUM ('A1', 'A2', 'B1', 'B2', 'C1', 'C2');

CREATE TYPE course_status AS ENUM ('draft', 'published', 'archived');

CREATE TYPE lesson_type AS ENUM ('video', 'document', 'mixed', 'live_link');

CREATE TYPE material_type AS ENUM ('video', 'document', 'audio', 'image', 'link');

CREATE TYPE enrollment_status AS ENUM ('active', 'completed', 'dropped', 'suspended');

CREATE TYPE progress_status AS ENUM ('not_started', 'in_progress', 'completed');
```

---

## 3. Core tables

### 3.1 profiles

Extends Supabase `auth.users`. Primary app user record.

```sql
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
CREATE INDEX idx_profiles_email ON profiles(email);
CREATE UNIQUE INDEX idx_profiles_email_unique ON profiles(LOWER(email));
```

### 3.2 centers

```sql
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
```

### 3.3 courses

```sql
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
CREATE INDEX idx_courses_center ON courses(center_id);
CREATE INDEX idx_courses_status ON courses(status);
CREATE INDEX idx_courses_language_level ON courses(language_taught, level);
```

### 3.4 course_modules

```sql
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

CREATE INDEX idx_modules_course ON course_modules(course_id);
```

### 3.5 lessons

```sql
CREATE TABLE lessons (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id       UUID NOT NULL REFERENCES course_modules(id) ON DELETE CASCADE,
    title           TEXT NOT NULL,
    description     TEXT,
    type            lesson_type NOT NULL DEFAULT 'mixed',
    sort_order      INT NOT NULL DEFAULT 0,
    duration_minutes INT,
    is_free_preview BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (module_id, sort_order)
);

CREATE INDEX idx_lessons_module ON lessons(module_id);
```

### 3.6 lesson_materials

Metadata only — files live in object storage.

```sql
CREATE TABLE lesson_materials (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id           UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    type                material_type NOT NULL,
    title               TEXT NOT NULL,
    storage_path        TEXT,           -- bucket path for uploaded files
    external_url        TEXT,           -- for link type or CDN/stream URL
    file_name           TEXT,
    mime_type           TEXT,
    file_size_bytes     BIGINT,
    duration_seconds    INT,            -- video/audio
    thumbnail_url       TEXT,
    sort_order          INT NOT NULL DEFAULT 0,
    is_downloadable     BOOLEAN NOT NULL DEFAULT TRUE,
    transcoding_status  TEXT DEFAULT 'ready',  -- pending, processing, ready, failed
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_materials_lesson ON lesson_materials(lesson_id);
```

### 3.7 batches

```sql
CREATE TABLE batches (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id       UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    instructor_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    center_id       UUID REFERENCES centers(id) ON DELETE SET NULL,
    name            TEXT NOT NULL,
    start_date      DATE,
    end_date        DATE,
    schedule        JSONB,              -- e.g. {"days": ["Mon","Wed"], "time": "18:00"}
    max_students    INT,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_batches_course ON batches(course_id);
CREATE INDEX idx_batches_instructor ON batches(instructor_id);
```

### 3.8 enrollments

```sql
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

CREATE INDEX idx_enrollments_student ON enrollments(student_id);
CREATE INDEX idx_enrollments_course ON enrollments(course_id);
CREATE INDEX idx_enrollments_batch ON enrollments(batch_id);
CREATE INDEX idx_enrollments_status ON enrollments(status);
```

### 3.9 lesson_progress

```sql
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

CREATE INDEX idx_progress_student ON lesson_progress(student_id);
CREATE INDEX idx_progress_lesson ON lesson_progress(lesson_id);
```

### 3.10 live_sessions

```sql
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

CREATE INDEX idx_sessions_course ON live_sessions(course_id);
CREATE INDEX idx_sessions_batch ON live_sessions(batch_id);
CREATE INDEX idx_sessions_start ON live_sessions(start_time);
```

### 3.11 notifications

```sql
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

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = FALSE;
```

### 3.12 audit_logs

```sql
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

CREATE INDEX idx_audit_actor ON audit_logs(actor_id);
CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);
```

---

## 4. Phase 2 tables (included for forward compatibility)

### 4.1 assignments

```sql
CREATE TABLE assignments (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id   UUID REFERENCES lessons(id) ON DELETE CASCADE,
    course_id   UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title       TEXT NOT NULL,
    description TEXT,
    due_date    TIMESTAMPTZ,
    max_score   INT NOT NULL DEFAULT 100,
    created_by  UUID NOT NULL REFERENCES profiles(id),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 4.2 submissions

```sql
CREATE TABLE submissions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_id   UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
    student_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    content_text    TEXT,
    storage_path    TEXT,
    score           INT,
    feedback        TEXT,
    submitted_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    graded_at       TIMESTAMPTZ,
    graded_by       UUID REFERENCES profiles(id),
    UNIQUE (assignment_id, student_id)
);
```

### 4.3 quizzes & questions

```sql
CREATE TYPE question_type AS ENUM ('multiple_choice', 'true_false', 'fill_blank');

CREATE TABLE quizzes (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id   UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    title       TEXT NOT NULL,
    pass_score  INT NOT NULL DEFAULT 70,
    time_limit_minutes INT,
    max_attempts INT DEFAULT 3,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE quiz_questions (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id     UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    type        question_type NOT NULL,
    question    TEXT NOT NULL,
    options     JSONB,          -- [{"id":"a","text":"..."}, ...]
    correct_answer TEXT NOT NULL,
    points      INT NOT NULL DEFAULT 1,
    sort_order  INT NOT NULL DEFAULT 0
);

CREATE TABLE quiz_attempts (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id     UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    student_id  UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    score       INT NOT NULL,
    passed      BOOLEAN NOT NULL,
    answers     JSONB NOT NULL,
    started_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 4.4 certificates

```sql
CREATE TABLE certificates (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    course_id       UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    verification_code TEXT NOT NULL UNIQUE,
    pdf_url         TEXT,
    issued_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (student_id, course_id)
);
```

---

## 5. Views

### 5.1 course_progress_view

Aggregates lesson completion per student per course.

```sql
CREATE OR REPLACE VIEW course_progress_view AS
SELECT
    e.student_id,
    e.course_id,
    e.status AS enrollment_status,
    COUNT(l.id) AS total_lessons,
    COUNT(lp.id) FILTER (WHERE lp.status = 'completed') AS completed_lessons,
    CASE
        WHEN COUNT(l.id) = 0 THEN 0
        ELSE ROUND(
            COUNT(lp.id) FILTER (WHERE lp.status = 'completed')::NUMERIC
            / COUNT(l.id) * 100, 1
        )
    END AS progress_percentage
FROM enrollments e
JOIN course_modules cm ON cm.course_id = e.course_id
JOIN lessons l ON l.module_id = cm.id
LEFT JOIN lesson_progress lp
    ON lp.lesson_id = l.id AND lp.student_id = e.student_id
WHERE e.status = 'active'
GROUP BY e.student_id, e.course_id, e.status;
```

### 5.2 admin_dashboard_stats

```sql
CREATE OR REPLACE VIEW admin_dashboard_stats AS
SELECT
    (SELECT COUNT(*) FROM profiles WHERE role = 'student' AND status = 'active') AS total_students,
    (SELECT COUNT(*) FROM profiles WHERE role = 'instructor' AND status = 'active') AS total_instructors,
    (SELECT COUNT(*) FROM courses WHERE status = 'published') AS active_courses,
    (SELECT COUNT(*) FROM enrollments WHERE enrolled_at >= NOW() - INTERVAL '7 days') AS enrollments_7d,
    (SELECT COUNT(*) FROM enrollments WHERE enrolled_at >= NOW() - INTERVAL '30 days') AS enrollments_30d;
```

---

## 6. Triggers

### 6.1 updated_at auto-update

```sql
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at column
CREATE TRIGGER trg_profiles_updated BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_courses_updated BEFORE UPDATE ON courses
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- ... repeat for other tables
```

### 6.2 Auto-create profile on signup

```sql
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
```

### 6.3 Auto-complete lesson at 90% video

```sql
CREATE OR REPLACE FUNCTION check_lesson_completion()
RETURNS TRIGGER AS $$
DECLARE
    video_duration INT;
BEGIN
    IF NEW.completion_percentage >= 90 THEN
        NEW.status = 'completed';
        NEW.completed_at = COALESCE(NEW.completed_at, NOW());
    ELSIF NEW.video_position_seconds > 0 THEN
        NEW.status = 'in_progress';
        NEW.started_at = COALESCE(NEW.started_at, NOW());
    END IF;
    NEW.last_accessed_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_lesson_progress_completion
    BEFORE INSERT OR UPDATE ON lesson_progress
    FOR EACH ROW EXECUTE FUNCTION check_lesson_completion();
```

---

## 7. Row Level Security (RLS) policies

Enable RLS on all tables. Key policies:

```sql
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_progress ENABLE ROW LEVEL SECURITY;

-- Profiles: users read own; admin reads all
CREATE POLICY profiles_select_own ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY profiles_select_admin ON profiles
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

CREATE POLICY profiles_update_own ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- Courses: anyone reads published; instructor reads own; admin all
CREATE POLICY courses_select_published ON courses
    FOR SELECT USING (status = 'published');

CREATE POLICY courses_select_instructor ON courses
    FOR SELECT USING (instructor_id = auth.uid());

CREATE POLICY courses_all_admin ON courses
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- Enrollments: student sees own; instructor sees course enrollments; admin all
CREATE POLICY enrollments_select_student ON enrollments
    FOR SELECT USING (student_id = auth.uid());

CREATE POLICY enrollments_select_instructor ON enrollments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = enrollments.course_id AND c.instructor_id = auth.uid()
        )
    );

-- Lesson materials: enrolled students + instructor + admin
CREATE POLICY materials_select_enrolled ON lesson_materials
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM lessons l
            JOIN course_modules cm ON cm.id = l.module_id
            JOIN enrollments e ON e.course_id = cm.course_id
            WHERE l.id = lesson_materials.lesson_id
              AND e.student_id = auth.uid()
              AND e.status = 'active'
        )
        OR EXISTS (
            SELECT 1 FROM lessons l
            JOIN course_modules cm ON cm.id = l.module_id
            JOIN courses c ON c.id = cm.course_id
            WHERE l.id = lesson_materials.lesson_id
              AND (c.instructor_id = auth.uid() OR l.is_free_preview = TRUE)
        )
    );

-- Lesson progress: student own only
CREATE POLICY progress_student_own ON lesson_progress
    FOR ALL USING (student_id = auth.uid());
```

---

## 8. Storage bucket structure

```
avatars/
  {user_id}/avatar.webp

course-thumbnails/
  {course_id}/thumbnail.webp

materials/
  {course_id}/{lesson_id}/{material_id}/{filename}

submissions/          (Phase 2)
  {assignment_id}/{student_id}/{filename}
```

---

## 9. Indexes summary

| Table | Index | Purpose |
|-------|-------|---------|
| courses | (language_taught, level) | Catalog filters |
| courses | (status) | Published catalog |
| enrollments | (student_id, course_id) UNIQUE | One enrollment per course |
| lesson_progress | (student_id, lesson_id) UNIQUE | Progress upsert |
| notifications | (user_id, is_read) partial | Unread count |
| audit_logs | (created_at DESC) | Recent activity |

---

## 10. Migration order

1. Enums
2. centers
3. profiles (+ auth trigger)
4. courses → course_modules → lessons → lesson_materials
5. batches → enrollments
6. lesson_progress
7. live_sessions
8. notifications → audit_logs
9. Views
10. RLS policies
11. Phase 2 tables (when ready)

---

## 11. Sample seed data (development)

```sql
-- Center
INSERT INTO centers (name, slug, timezone) VALUES
('Main Language Center', 'main-center', 'Africa/Cairo');

-- Admin profile created via Supabase Auth dashboard, then:
UPDATE profiles SET role = 'admin', status = 'active', full_name = 'System Admin'
WHERE email = 'admin@lms.local';
```

---

## 12. Document history

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-23 | Initial schema for MVP + Phase 2 forward compatibility |
