class RouteNames {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  static const adminDashboard = '/admin/dashboard';
  static const adminUsers = '/admin/users';
  static const adminCenters = '/admin/centers';

  static const instructorDashboard = '/instructor/dashboard';
  static const instructorCourses = '/instructor/courses';
  static const instructorCourseNew = '/instructor/courses/new';
  static const instructorBatches = '/instructor/batches';
  static const instructorBatchNew = '/instructor/batches/new';

  static String instructorBatchDetail(String batchId) =>
      '/instructor/batches/$batchId';

  static String instructorBatchEdit(String batchId) =>
      '/instructor/batches/$batchId/edit';

  static const profileEdit = '/profile/edit';

  static const studentDashboard = '/student/dashboard';
  static const studentCatalog = '/student/catalog';
  static const studentMyCourses = '/student/my-courses';

  static const profile = '/profile';
  static const notifications = '/notifications';

  static String instructorCourseEdit(String courseId) =>
      '/instructor/courses/$courseId';

  static String instructorCourseEditForm(String courseId) =>
      '/instructor/courses/$courseId/form';

  static String instructorLessonEdit(String courseId, String lessonId) =>
      '/instructor/courses/$courseId/lessons/$lessonId';

  static String studentCourseDetail(String courseId) =>
      '/student/courses/$courseId';

  static String studentLessonPlayer(String courseId, String lessonId) =>
      '/student/courses/$courseId/lessons/$lessonId';
}
