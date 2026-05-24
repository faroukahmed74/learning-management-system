import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../shared/domain/enums/user_role.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/role_adaptive_shell.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../courses/presentation/providers/courses_provider.dart';
import '../../../../shared/widgets/responsive_content.dart';
import 'student_dashboard_screen.dart';

class StudentCatalogScreen extends ConsumerWidget {
  const StudentCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(publishedCoursesProvider);

    return RoleAdaptiveShell(
      role: UserRole.student,
      title: 'Course Catalog',
      items: StudentDashboardScreen.shellItems,
      child: coursesAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading catalog...'),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(publishedCoursesProvider),
        ),
        data: (courses) {
          if (courses.isEmpty) {
            return const EmptyState(
              title: 'No courses available',
              subtitle: 'Published courses will appear here.',
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
                  onTap: () => context.push(RouteNames.studentCourseDetail(course.id)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class StudentCourseDetailScreen extends ConsumerWidget {
  const StudentCourseDetailScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseDetailProvider(courseId));
    final modulesAsync = ref.watch(courseModulesProvider(courseId));

    return Scaffold(
      appBar: AppBar(
        title: courseAsync.maybeWhen(
          data: (c) => Text(c?.title ?? 'Course'),
          orElse: () => const Text('Course'),
        ),
      ),
      body: courseAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (course) {
          if (course == null) return const Center(child: Text('Not found'));

          return modulesAsync.when(
            loading: () => const LoadingIndicator(),
            error: (e, _) => ErrorView(message: e.toString()),
            data: (modules) => ResponsiveContent(
              maxWidth: 960,
              child: ListView(
                children: [
                  if (course.description != null && course.description!.isNotEmpty)
                    Text(course.description!, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  ...modules.map(
                    (module) => _ModuleLessonsList(
                      courseId: courseId,
                      module: module,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ModuleLessonsList extends ConsumerWidget {
  const _ModuleLessonsList({required this.courseId, required this.module});

  final String courseId;
  final CourseModule module;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(courseRepositoryProvider).getLessons(module.id),
      builder: (context, snapshot) {
        final lessons = snapshot.data ?? [];
        if (lessons.isEmpty) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(module.title),
            children: lessons
                .map(
                  (lesson) => ListTile(
                    leading: const Icon(Icons.play_circle_outline),
                    title: Text(lesson.title),
                    onTap: () => context.push(
                      RouteNames.studentLessonPlayer(courseId, lesson.id),
                    ),
                  ),
                )
                .toList(),
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
