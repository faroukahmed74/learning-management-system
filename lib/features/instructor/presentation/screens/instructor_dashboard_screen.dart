import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/domain/enums/user_role.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../../../shared/widgets/role_adaptive_shell.dart';

class InstructorDashboardScreen extends StatelessWidget {
  const InstructorDashboardScreen({super.key});

  static List<ShellDestination> shellItems(AppLocalizations l10n) => [
        ShellDestination(
          route: RouteNames.instructorDashboard,
          destination: NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
        ),
        ShellDestination(
          route: RouteNames.instructorCourses,
          destination: NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: l10n.courses,
          ),
        ),
        ShellDestination(
          route: RouteNames.instructorBatches,
          destination: NavigationDestination(
            icon: const Icon(Icons.groups_outlined),
            selectedIcon: const Icon(Icons.groups),
            label: l10n.batches,
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return RoleAdaptiveShell(
      role: UserRole.instructor,
      title: l10n.instructorDashboard,
      items: shellItems(l10n),
      child: ResponsiveContent(
        child: ListView(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book),
                title: Text(l10n.myCoursesTitle),
                subtitle: Text(l10n.createManageCourses),
                onTap: () => context.go(RouteNames.instructorCourses),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.upload_file),
                title: Text(l10n.uploadMaterials),
                subtitle: Text(l10n.uploadMaterialsDesc),
                onTap: () => context.go(RouteNames.instructorCourses),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.video_call),
                title: Text(l10n.liveSessions),
                subtitle: Text(l10n.liveSessionsDesc),
                onTap: () => context.go(RouteNames.instructorBatches),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
