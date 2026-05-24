import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/env.dart';
import '../../../../core/router/route_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/domain/enums/user_role.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../../../shared/widgets/role_adaptive_shell.dart';
import '../../../instructor/presentation/screens/instructor_dashboard_screen.dart';
import '../../domain/entities/course.dart';
import '../providers/courses_provider.dart';

class InstructorCoursesScreen extends ConsumerWidget {
  const InstructorCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final coursesAsync = ref.watch(instructorCoursesProvider);

    return RoleAdaptiveShell(
      role: UserRole.instructor,
      title: l10n.myCoursesTitle,
      items: InstructorDashboardScreen.shellItems(l10n),
      child: Stack(
        children: [
          coursesAsync.when(
            loading: () => LoadingIndicator(message: l10n.loadingCourses),
            error: (error, _) => ErrorView(
              error: error,
              onRetry: () => ref.invalidate(instructorCoursesProvider),
            ),
            data: (courses) {
              if (courses.isEmpty) {
                return EmptyState(
                  title: l10n.noCoursesYet,
                  subtitle: Env.isConfigured
                      ? l10n.createFirstCourse
                      : l10n.configureSupabase,
                  icon: Icons.menu_book_outlined,
                  action: Env.isConfigured
                      ? FilledButton.icon(
                          onPressed: () =>
                              context.push(RouteNames.instructorCourseNew),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.createCourse),
                        )
                      : null,
                );
              }

              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(instructorCoursesProvider),
                child: ResponsiveContent(
                  child: ListView.separated(
                    itemCount: courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return _CourseCard(
                        course: course,
                        onTap: () => context.push(
                          RouteNames.instructorCourseEdit(course.id),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          if (Env.isConfigured)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                onPressed: () => context.push(RouteNames.instructorCourseNew),
                icon: const Icon(Icons.add),
                label: Text(l10n.newCourse),
              ),
            ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.onTap});

  final Course course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(course.level.label)),
        title: Text(course.title),
        subtitle: Text('${course.languageTaught} · ${course.status.label}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
