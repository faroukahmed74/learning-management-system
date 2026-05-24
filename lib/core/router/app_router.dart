import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env.dart';
import '../../core/router/route_guards.dart';
import '../../core/router/route_names.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/batches/presentation/screens/instructor_batches_screen.dart';
import '../../features/batches/presentation/screens/batch_form_screen.dart';
import '../../features/batches/presentation/screens/batch_detail_screen.dart';
import '../../features/courses/presentation/screens/instructor_courses_screen.dart';
import '../../features/courses/presentation/screens/course_form_screen.dart';
import '../../features/courses/presentation/screens/course_editor_screen.dart';
import '../../features/student/presentation/screens/student_catalog_screen.dart';
import '../../features/lessons/presentation/screens/lesson_editor_screen.dart';
import '../../features/lessons/presentation/screens/lesson_player_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/instructor/presentation/screens/instructor_dashboard_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/profile_edit_screen.dart';
import '../../features/student/presentation/screens/student_dashboard_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRefresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, __) => authRefresh.value++);

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final session = _activeSession(ref);
      final user = ref.read(currentUserProvider).valueOrNull;

      return resolveRouteRedirect(
        location: state.uri.path,
        envConfigured: Env.isConfigured,
        hasSession: session != null,
        role: user?.role,
      );
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.profileEdit,
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Admin — flat routes so section tabs always navigate correctly.
      GoRoute(
        path: '/admin',
        redirect: (_, __) => RouteNames.adminDashboard,
      ),
      GoRoute(
        path: RouteNames.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.adminUsers,
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: RouteNames.adminCenters,
        builder: (context, state) => const AdminCentersScreen(),
      ),

      // Instructor
      GoRoute(
        path: '/instructor',
        redirect: (_, __) => RouteNames.instructorDashboard,
      ),
      GoRoute(
        path: RouteNames.instructorDashboard,
        builder: (context, state) => const InstructorDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.instructorCourses,
        builder: (context, state) => const InstructorCoursesScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const CourseFormScreen(),
          ),
          GoRoute(
            path: ':courseId',
            builder: (context, state) => CourseEditorScreen(
              courseId: state.pathParameters['courseId']!,
            ),
            routes: [
              GoRoute(
                path: 'form',
                builder: (context, state) => CourseFormScreen(
                  courseId: state.pathParameters['courseId'],
                ),
              ),
              GoRoute(
                path: 'lessons/:lessonId',
                builder: (context, state) => LessonEditorScreen(
                  courseId: state.pathParameters['courseId']!,
                  lessonId: state.pathParameters['lessonId']!,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.instructorBatches,
        builder: (context, state) => const InstructorBatchesScreen(),
      ),
      GoRoute(
        path: RouteNames.instructorBatchNew,
        builder: (context, state) => const BatchFormScreen(),
      ),
      GoRoute(
        path: '/instructor/batches/:batchId',
        builder: (context, state) => BatchDetailScreen(
          batchId: state.pathParameters['batchId']!,
        ),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => BatchFormScreen(
              batchId: state.pathParameters['batchId'],
            ),
          ),
        ],
      ),

      // Student
      GoRoute(
        path: '/student',
        redirect: (_, __) => RouteNames.studentDashboard,
      ),
      GoRoute(
        path: RouteNames.studentDashboard,
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.studentCatalog,
        builder: (context, state) => const StudentCatalogScreen(),
      ),
      GoRoute(
        path: RouteNames.studentMyCourses,
        builder: (context, state) => const StudentMyCoursesScreen(),
      ),
      GoRoute(
        path: '/student/courses/:courseId',
        builder: (context, state) => StudentCourseDetailScreen(
          courseId: state.pathParameters['courseId']!,
        ),
        routes: [
          GoRoute(
            path: 'lessons/:lessonId',
            builder: (context, state) => LessonPlayerScreen(
              courseId: state.pathParameters['courseId']!,
              lessonId: state.pathParameters['lessonId']!,
            ),
          ),
        ],
      ),
    ],
  );
});

Session? _activeSession(Ref ref) {
  final fromStream = ref.read(authStateProvider).valueOrNull?.session;
  if (fromStream != null) return fromStream;
  if (!Env.isConfigured) return null;
  return Supabase.instance.client.auth.currentSession;
}

class _SplashScreen extends ConsumerWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authStateProvider);
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const LoadingIndicator(message: 'Loading...'),
      error: (_, __) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go(RouteNames.login);
        });
        return const LoadingIndicator();
      },
      data: (user) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          if (user == null) {
            context.go(RouteNames.login);
          } else {
            context.go(homeRouteForRole(user.role));
          }
        });
        return const LoadingIndicator(message: 'Loading...');
      },
    );
  }
}
