import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/domain/enums/user_role.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../../../shared/widgets/role_adaptive_shell.dart';
import '../../../enrollments/presentation/providers/enrollments_provider.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  static List<ShellDestination> shellItems(AppLocalizations l10n) => [
        ShellDestination(
          route: RouteNames.studentDashboard,
          destination: NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
        ),
        ShellDestination(
          route: RouteNames.studentCatalog,
          destination: NavigationDestination(
            icon: const Icon(Icons.search),
            label: l10n.catalog,
          ),
        ),
        ShellDestination(
          route: RouteNames.studentMyCourses,
          destination: NavigationDestination(
            icon: const Icon(Icons.play_lesson_outlined),
            selectedIcon: const Icon(Icons.play_lesson),
            label: l10n.myCourses,
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return RoleAdaptiveShell(
      role: UserRole.student,
      title: l10n.studentHome,
      items: shellItems(l10n),
      child: ResponsiveContent(
        child: ListView(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: Text(l10n.continueLearning),
                subtitle: Text(l10n.browseEnrolled),
                onTap: () => context.go(RouteNames.studentMyCourses),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.search),
                title: Text(l10n.browseCatalog),
                subtitle: Text(l10n.findCourses),
                onTap: () => context.go(RouteNames.studentCatalog),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentMyCoursesScreen extends ConsumerWidget {
  const StudentMyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final enrollmentsAsync = ref.watch(studentEnrollmentsProvider);

    return RoleAdaptiveShell(
      role: UserRole.student,
      title: l10n.myCourses,
      items: StudentDashboardScreen.shellItems(l10n),
      child: enrollmentsAsync.when(
        loading: () => LoadingIndicator(message: l10n.loadingCourses),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(studentEnrollmentsProvider),
        ),
        data: (enrollments) {
          if (enrollments.isEmpty) {
            return ResponsiveContent(
              child: EmptyState(
                title: l10n.notEnrolledYet,
                subtitle: l10n.enrollFromCatalog,
                icon: Icons.play_lesson_outlined,
                action: FilledButton(
                  onPressed: () => context.go(RouteNames.studentCatalog),
                  child: Text(l10n.browseCatalog),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(studentEnrollmentsProvider),
            child: ResponsiveContent(
              child: ListView.separated(
                itemCount: enrollments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final enrollment = enrollments[index];
                  final course = enrollment.course;
                  if (course == null) return const SizedBox.shrink();

                  final percent = enrollment.progressPercent ?? 0;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text(course.level.label)),
                      title: Text(course.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${course.languageTaught} · ${course.level.label}'),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: percent / 100),
                          const SizedBox(height: 4),
                          Text('$percent%'),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          context.push(RouteNames.studentCourseDetail(course.id)),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
