import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../shared/domain/enums/user_role.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../../../shared/widgets/role_adaptive_shell.dart';

class InstructorDashboardScreen extends StatelessWidget {
  const InstructorDashboardScreen({super.key});

  static const shellItems = [
    ShellDestination(
      route: RouteNames.instructorDashboard,
      destination: NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
    ),
    ShellDestination(
      route: RouteNames.instructorCourses,
      destination: NavigationDestination(
        icon: Icon(Icons.menu_book_outlined),
        selectedIcon: Icon(Icons.menu_book),
        label: 'Courses',
      ),
    ),
    ShellDestination(
      route: RouteNames.instructorBatches,
      destination: NavigationDestination(
        icon: Icon(Icons.groups_outlined),
        selectedIcon: Icon(Icons.groups),
        label: 'Batches',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return RoleAdaptiveShell(
      role: UserRole.instructor,
      title: 'Instructor Dashboard',
      items: shellItems,
      child: ResponsiveContent(
        child: ListView(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book),
                title: const Text('My Courses'),
                subtitle: const Text('Create and manage your courses'),
                onTap: () => context.go(RouteNames.instructorCourses),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Upload Materials'),
                subtitle: const Text('Videos, PDFs, audio for lessons'),
                onTap: () => context.go(RouteNames.instructorCourses),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.video_call),
                title: const Text('Live Sessions'),
                subtitle: const Text('Schedule classes with meeting links'),
                onTap: () => context.go(RouteNames.instructorBatches),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InstructorBatchesScreen extends StatelessWidget {
  const InstructorBatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleAdaptiveShell(
      role: UserRole.instructor,
      title: 'Batches',
      items: InstructorDashboardScreen.shellItems,
      child: const ResponsiveContent(
        child: EmptyState(
          title: 'No batches yet',
          subtitle: 'Create class groups and assign students.',
          icon: Icons.groups_outlined,
        ),
      ),
    );
  }
}
