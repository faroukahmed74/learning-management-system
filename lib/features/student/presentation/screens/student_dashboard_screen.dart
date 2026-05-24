import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../shared/domain/enums/user_role.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../../../shared/widgets/role_adaptive_shell.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  static const shellItems = [
    ShellDestination(
      route: RouteNames.studentDashboard,
      destination: NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
    ),
    ShellDestination(
      route: RouteNames.studentCatalog,
      destination: NavigationDestination(
        icon: Icon(Icons.search),
        label: 'Catalog',
      ),
    ),
    ShellDestination(
      route: RouteNames.studentMyCourses,
      destination: NavigationDestination(
        icon: Icon(Icons.play_lesson_outlined),
        selectedIcon: Icon(Icons.play_lesson),
        label: 'My Courses',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return RoleAdaptiveShell(
      role: UserRole.student,
      title: 'Student Home',
      items: shellItems,
      child: ResponsiveContent(
        child: ListView(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: const Text('Continue Learning'),
                subtitle: const Text('Browse your enrolled courses'),
                onTap: () => context.go(RouteNames.studentMyCourses),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Browse Catalog'),
                subtitle: const Text('Find courses to enroll in'),
                onTap: () => context.go(RouteNames.studentCatalog),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentMyCoursesScreen extends StatelessWidget {
  const StudentMyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleAdaptiveShell(
      role: UserRole.student,
      title: 'My Courses',
      items: StudentDashboardScreen.shellItems,
      child: const ResponsiveContent(
        child: EmptyState(
          title: 'Not enrolled yet',
          subtitle: 'Browse the catalog and enroll in a course.',
          icon: Icons.play_lesson_outlined,
        ),
      ),
    );
  }
}
