import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/domain/enums/cefr_level.dart';
import '../../../../shared/domain/enums/progress_status.dart';
import '../../../../shared/domain/enums/user_role.dart';
import '../../../../shared/widgets/app_settings_controls.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../../../shared/widgets/role_adaptive_shell.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../courses/presentation/providers/courses_provider.dart';
import '../../../enrollments/presentation/providers/enrollments_provider.dart';
import '../../../progress/presentation/providers/progress_provider.dart';
import 'student_dashboard_screen.dart';

final catalogFilterProvider = StateProvider<CatalogFilter>((ref) {
  return const CatalogFilter();
});

class StudentCatalogScreen extends ConsumerWidget {
  const StudentCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filter = ref.watch(catalogFilterProvider);
    final coursesAsync = ref.watch(publishedCoursesProvider(filter));

    return RoleAdaptiveShell(
      role: UserRole.student,
      title: l10n.courseCatalog,
      items: StudentDashboardScreen.shellItems(l10n),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _CatalogFilters(
              filter: filter,
              onChanged: (f) => ref.read(catalogFilterProvider.notifier).state = f,
            ),
          ),
          Expanded(
            child: coursesAsync.when(
              loading: () => LoadingIndicator(message: l10n.loadingCatalog),
              error: (e, _) => ErrorView(
                error: e,
                onRetry: () => ref.invalidate(publishedCoursesProvider(filter)),
              ),
              data: (courses) {
                if (courses.isEmpty) {
                  return EmptyState(
                    title: l10n.noCoursesFound,
                    subtitle: l10n.tryDifferentSearch,
                    icon: Icons.search,
                  );
                }

                return ResponsiveContent(
                  child: ListView.separated(
                    itemCount: courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return _CatalogCourseCard(
                        course: course,
                        onTap: () =>
                            context.push(RouteNames.studentCourseDetail(course.id)),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogFilters extends StatelessWidget {
  const _CatalogFilters({required this.filter, required this.onChanged});

  final CatalogFilter filter;
  final ValueChanged<CatalogFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: l10n.searchCourses,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (q) =>
                onChanged(CatalogFilter(query: q, level: filter.level)),
          ),
        ),
        const SizedBox(width: 12),
        DropdownButton<String?>(
          value: filter.level,
          hint: Text(l10n.level),
          items: [
            DropdownMenuItem(value: null, child: Text(l10n.allLevels)),
            ...CefrLevel.values.map(
              (l) => DropdownMenuItem(value: l.label, child: Text(l.label)),
            ),
          ],
          onChanged: (level) =>
              onChanged(CatalogFilter(query: filter.query, level: level)),
        ),
      ],
    );
  }
}

class StudentCourseDetailScreen extends ConsumerWidget {
  const StudentCourseDetailScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final courseAsync = ref.watch(courseDetailProvider(courseId));
    final modulesAsync = ref.watch(courseModulesProvider(courseId));
    final enrolledAsync = ref.watch(isEnrolledProvider(courseId));
    final progressAsync = ref.watch(courseProgressSummaryProvider(courseId));
    final lessonProgressMapAsync =
        ref.watch(courseLessonProgressMapProvider(courseId));

    return Scaffold(
      appBar: AppBar(
        title: courseAsync.maybeWhen(
          data: (c) => Text(c?.title ?? l10n.course),
          orElse: () => Text(l10n.course),
        ),
        actions: const [AppSettingsControls(compact: true)],
      ),
      body: courseAsync.when(
        loading: () => LoadingIndicator(message: l10n.loading),
        error: (e, _) => ErrorView(error: e),
        data: (course) {
          if (course == null) {
            return Center(child: Text(l10n.notFound));
          }

          return ResponsiveContent(
            maxWidth: 960,
            child: ListView(
              children: [
                if (course.description != null && course.description!.isNotEmpty)
                  Text(
                    course.description!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                const SizedBox(height: 16),
                enrolledAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text(l10n.friendlyError(e)),
                  data: (enrolled) {
                    if (enrolled) {
                      return progressAsync.when(
                        data: (summary) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            LinearProgressIndicator(
                              value: summary.percent / 100,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.percentComplete(
                                summary.percent,
                                summary.completedLessons,
                                summary.totalLessons,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    }

                    return FilledButton.icon(
                      onPressed: () async {
                        final user = await ref.read(currentUserProvider.future);
                        if (user == null) return;
                        try {
                          await ref
                              .read(enrollmentRepositoryProvider)
                              .enrollStudent(
                                studentId: user.id,
                                courseId: courseId,
                              );
                          ref.invalidate(isEnrolledProvider(courseId));
                          ref.invalidate(studentEnrollmentsProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.enrolledSuccess)),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            showErrorSnackBar(context, e);
                          }
                        }
                      },
                      icon: const Icon(Icons.school),
                      label: Text(l10n.enrollInCourse),
                    );
                  },
                ),
                const SizedBox(height: 16),
                modulesAsync.when(
                  loading: () => LoadingIndicator(message: l10n.loading),
                  error: (e, _) => ErrorView(error: e),
                  data: (modules) => Column(
                    children: modules
                        .map(
                          (module) => _ModuleLessonsList(
                            courseId: courseId,
                            module: module,
                            enrolled: enrolledAsync.valueOrNull ?? false,
                            progressMap:
                                lessonProgressMapAsync.valueOrNull ?? {},
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ModuleLessonsList extends ConsumerWidget {
  const _ModuleLessonsList({
    required this.courseId,
    required this.module,
    required this.enrolled,
    required this.progressMap,
  });

  final String courseId;
  final CourseModule module;
  final bool enrolled;
  final Map<String, LessonProgressRecord> progressMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return FutureBuilder(
      future: ref.read(courseRepositoryProvider).getLessons(module.id),
      builder: (context, snapshot) {
        final lessons = snapshot.data ?? [];
        if (lessons.isEmpty) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(module.title),
            children: lessons.map((lesson) {
              final canAccess = enrolled || lesson.isFreePreview;
              final progress = progressMap[lesson.id];
              return ListTile(
                leading: Icon(
                  progress?.status == ProgressStatus.completed
                      ? Icons.check_circle
                      : Icons.play_circle_outline,
                  color: progress?.status == ProgressStatus.completed
                      ? Colors.green
                      : null,
                ),
                title: Text(lesson.title),
                subtitle: lesson.isFreePreview
                    ? Text(l10n.freePreview)
                    : (!enrolled ? Text(l10n.enrollToUnlock) : null),
                enabled: canAccess,
                onTap: canAccess
                    ? () => context.push(
                          RouteNames.studentLessonPlayer(courseId, lesson.id),
                        )
                    : null,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _CatalogCourseCard extends StatelessWidget {
  const _CatalogCourseCard({required this.course, required this.onTap});

  final Course course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(course.level.label)),
        title: Text(course.title),
        subtitle: Text('${course.languageTaught} · ${course.level.label}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
