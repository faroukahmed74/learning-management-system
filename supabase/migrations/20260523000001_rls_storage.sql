-- Step 2: RLS policies, storage buckets, triggers, helper functions

-- Helper functions (SECURITY DEFINER to avoid RLS recursion)
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
  );
$$;

CREATE OR REPLACE FUNCTION public.is_instructor()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('instructor', 'admin')
  );
$$;

CREATE OR REPLACE FUNCTION public.is_enrolled_in_course(p_course_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM enrollments
    WHERE student_id = auth.uid()
      AND course_id = p_course_id
      AND status = 'active'
  );
$$;

-- updated_at trigger function
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_centers_updated BEFORE UPDATE ON centers
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_profiles_updated BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_courses_updated BEFORE UPDATE ON courses
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_modules_updated BEFORE UPDATE ON course_modules
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_lessons_updated BEFORE UPDATE ON lessons
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_materials_updated BEFORE UPDATE ON lesson_materials
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_batches_updated BEFORE UPDATE ON batches
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_enrollments_updated BEFORE UPDATE ON enrollments
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_progress_updated BEFORE UPDATE ON lesson_progress
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Lesson auto-completion trigger
CREATE OR REPLACE FUNCTION public.check_lesson_completion()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.completion_percentage >= 90 THEN
        NEW.status = 'completed';
        NEW.completed_at = COALESCE(NEW.completed_at, NOW());
    ELSIF NEW.video_position_seconds > 0 OR NEW.completion_percentage > 0 THEN
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

-- Enable RLS on all tables
ALTER TABLE centers ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE live_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Drop partial policies from migration 1 if re-running
DROP POLICY IF EXISTS profiles_select_own ON profiles;
DROP POLICY IF EXISTS profiles_update_own ON profiles;
DROP POLICY IF EXISTS courses_select_published ON courses;
DROP POLICY IF EXISTS enrollments_select_student ON enrollments;
DROP POLICY IF EXISTS progress_student_own ON lesson_progress;

-- PROFILES
CREATE POLICY profiles_select_own ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY profiles_select_admin ON profiles FOR SELECT USING (is_admin());
CREATE POLICY profiles_select_instructor ON profiles FOR SELECT
    USING (is_instructor() AND role = 'student');
CREATE POLICY profiles_update_own ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY profiles_update_admin ON profiles FOR UPDATE USING (is_admin());
CREATE POLICY profiles_insert_admin ON profiles FOR INSERT WITH CHECK (is_admin());

-- CENTERS
CREATE POLICY centers_select_all ON centers FOR SELECT USING (true);
CREATE POLICY centers_all_admin ON centers FOR ALL USING (is_admin());

-- COURSES
CREATE POLICY courses_select_published ON courses FOR SELECT USING (status = 'published');
CREATE POLICY courses_select_instructor ON courses FOR SELECT
    USING (instructor_id = auth.uid() OR is_admin());
CREATE POLICY courses_insert_instructor ON courses FOR INSERT
    WITH CHECK (instructor_id = auth.uid() AND is_instructor());
CREATE POLICY courses_update_instructor ON courses FOR UPDATE
    USING (instructor_id = auth.uid() OR is_admin());
CREATE POLICY courses_delete_instructor ON courses FOR DELETE
    USING (instructor_id = auth.uid() OR is_admin());

-- COURSE MODULES
CREATE POLICY modules_select ON course_modules FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM courses c WHERE c.id = course_modules.course_id
        AND (c.status = 'published' OR c.instructor_id = auth.uid() OR is_admin())
    )
);
CREATE POLICY modules_write ON course_modules FOR ALL USING (
    EXISTS (
        SELECT 1 FROM courses c WHERE c.id = course_modules.course_id
        AND (c.instructor_id = auth.uid() OR is_admin())
    )
);

-- LESSONS
CREATE POLICY lessons_select ON lessons FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM course_modules cm
        JOIN courses c ON c.id = cm.course_id
        WHERE cm.id = lessons.module_id
        AND (
            c.status = 'published'
            OR c.instructor_id = auth.uid()
            OR is_admin()
            OR lessons.is_free_preview = TRUE
        )
    )
    OR EXISTS (
        SELECT 1 FROM course_modules cm
        JOIN courses c ON c.id = cm.course_id
        WHERE cm.id = lessons.module_id
        AND is_enrolled_in_course(c.id)
    )
);
CREATE POLICY lessons_write ON lessons FOR ALL USING (
    EXISTS (
        SELECT 1 FROM course_modules cm
        JOIN courses c ON c.id = cm.course_id
        WHERE cm.id = lessons.module_id
        AND (c.instructor_id = auth.uid() OR is_admin())
    )
);

-- LESSON MATERIALS
CREATE POLICY materials_select ON lesson_materials FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM lessons l
        JOIN course_modules cm ON cm.id = l.module_id
        JOIN courses c ON c.id = cm.course_id
        WHERE l.id = lesson_materials.lesson_id
        AND (
            c.instructor_id = auth.uid()
            OR is_admin()
            OR l.is_free_preview = TRUE
            OR is_enrolled_in_course(c.id)
        )
    )
);
CREATE POLICY materials_write ON lesson_materials FOR ALL USING (
    EXISTS (
        SELECT 1 FROM lessons l
        JOIN course_modules cm ON cm.id = l.module_id
        JOIN courses c ON c.id = cm.course_id
        WHERE l.id = lesson_materials.lesson_id
        AND (c.instructor_id = auth.uid() OR is_admin())
    )
);

-- ENROLLMENTS
CREATE POLICY enrollments_select_student ON enrollments FOR SELECT
    USING (student_id = auth.uid());
CREATE POLICY enrollments_select_instructor ON enrollments FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM courses c
        WHERE c.id = enrollments.course_id
        AND (c.instructor_id = auth.uid() OR is_admin())
    )
);
CREATE POLICY enrollments_insert ON enrollments FOR INSERT WITH CHECK (
    student_id = auth.uid()
    OR is_admin()
    OR EXISTS (
        SELECT 1 FROM courses c
        WHERE c.id = enrollments.course_id AND c.instructor_id = auth.uid()
    )
);
CREATE POLICY enrollments_update ON enrollments FOR UPDATE USING (
    is_admin()
    OR EXISTS (
        SELECT 1 FROM courses c
        WHERE c.id = enrollments.course_id AND c.instructor_id = auth.uid()
    )
);

-- LESSON PROGRESS
CREATE POLICY progress_student_own ON lesson_progress FOR ALL
    USING (student_id = auth.uid());
CREATE POLICY progress_instructor_read ON lesson_progress FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM lessons l
        JOIN course_modules cm ON cm.id = l.module_id
        JOIN courses c ON c.id = cm.course_id
        WHERE l.id = lesson_progress.lesson_id
        AND (c.instructor_id = auth.uid() OR is_admin())
    )
);

-- BATCHES
CREATE POLICY batches_select ON batches FOR SELECT USING (
    instructor_id = auth.uid() OR is_admin()
    OR EXISTS (
        SELECT 1 FROM enrollments e
        WHERE e.batch_id = batches.id AND e.student_id = auth.uid()
    )
);
CREATE POLICY batches_write ON batches FOR ALL USING (
    instructor_id = auth.uid() OR is_admin()
);

-- LIVE SESSIONS
CREATE POLICY sessions_select ON live_sessions FOR SELECT USING (
    instructor_id = auth.uid() OR is_admin()
    OR is_enrolled_in_course(course_id)
);
CREATE POLICY sessions_write ON live_sessions FOR ALL USING (
    instructor_id = auth.uid() OR is_admin()
);

-- NOTIFICATIONS
CREATE POLICY notifications_own ON notifications FOR ALL
    USING (user_id = auth.uid());

-- AUDIT LOGS
CREATE POLICY audit_admin ON audit_logs FOR SELECT USING (is_admin());
CREATE POLICY audit_insert ON audit_logs FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Storage buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES
    ('avatars', 'avatars', true, 2097152),
    ('course-thumbnails', 'course-thumbnails', true, 5242880),
    ('materials', 'materials', false, 524288000)
ON CONFLICT (id) DO NOTHING;

-- Storage policies: avatars
CREATE POLICY avatars_public_read ON storage.objects FOR SELECT
    USING (bucket_id = 'avatars');
CREATE POLICY avatars_upload ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY avatars_update ON storage.objects FOR UPDATE
    USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Storage policies: course-thumbnails
CREATE POLICY thumbnails_public_read ON storage.objects FOR SELECT
    USING (bucket_id = 'course-thumbnails');
CREATE POLICY thumbnails_upload ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'course-thumbnails' AND is_instructor());
CREATE POLICY thumbnails_update ON storage.objects FOR UPDATE
    USING (bucket_id = 'course-thumbnails' AND is_instructor());

-- Storage policies: materials (private)
CREATE POLICY materials_read ON storage.objects FOR SELECT
    USING (bucket_id = 'materials' AND auth.uid() IS NOT NULL);
CREATE POLICY materials_upload ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'materials' AND is_instructor());
CREATE POLICY materials_delete ON storage.objects FOR DELETE
    USING (bucket_id = 'materials' AND is_instructor());

-- Admin dashboard stats view
CREATE OR REPLACE VIEW admin_dashboard_stats AS
SELECT
    (SELECT COUNT(*) FROM profiles WHERE role = 'student' AND status = 'active') AS total_students,
    (SELECT COUNT(*) FROM profiles WHERE role = 'instructor' AND status = 'active') AS total_instructors,
    (SELECT COUNT(*) FROM courses WHERE status = 'published') AS active_courses,
    (SELECT COUNT(*) FROM enrollments WHERE enrolled_at >= NOW() - INTERVAL '7 days') AS enrollments_7d,
    (SELECT COUNT(*) FROM enrollments WHERE enrolled_at >= NOW() - INTERVAL '30 days') AS enrollments_30d;
