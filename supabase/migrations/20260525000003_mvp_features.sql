-- MVP features: enrollment notifications, admin stats access, profile fields

-- Allow authenticated users to read dashboard stats (admin screen)
GRANT SELECT ON admin_dashboard_stats TO authenticated;

-- Notify student on enrollment
CREATE OR REPLACE FUNCTION public.notify_on_enrollment()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_course_title TEXT;
BEGIN
  SELECT title INTO v_course_title FROM courses WHERE id = NEW.course_id;

  INSERT INTO notifications (user_id, title, body, type, data)
  VALUES (
    NEW.student_id,
    'Enrollment confirmed',
    COALESCE('You are now enrolled in ' || v_course_title, 'You are enrolled in a new course.'),
    'enrollment',
    jsonb_build_object('course_id', NEW.course_id, 'enrollment_id', NEW.id)
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_enrollment ON enrollments;
CREATE TRIGGER trg_notify_enrollment
  AFTER INSERT ON enrollments
  FOR EACH ROW EXECUTE FUNCTION notify_on_enrollment();

-- Instructors can create notifications for their students
DROP POLICY IF EXISTS notifications_insert_staff ON notifications;
CREATE POLICY notifications_insert_staff ON notifications FOR INSERT
  WITH CHECK (is_admin() OR is_instructor());
