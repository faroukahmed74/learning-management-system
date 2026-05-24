import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../providers/courses_provider.dart';

class CourseEditorScreen extends ConsumerWidget {
  const CourseEditorScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseDetailProvider(courseId));
    final modulesAsync = ref.watch(courseModulesProvider(courseId));

    return Scaffold(
      appBar: AppBar(
        title: courseAsync.maybeWhen(
          data: (course) => Text(course?.title ?? 'Course'),
          orElse: () => const Text('Course Editor'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(
              RouteNames.instructorCourseEditForm(courseId),
            ),
          ),
        ],
      ),
      body: courseAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () {
            ref.invalidate(courseDetailProvider(courseId));
            ref.invalidate(courseModulesProvider(courseId));
          },
        ),
        data: (course) {
          if (course == null) {
            return const Center(child: Text('Course not found'));
          }

          return ResponsiveContent(
            maxWidth: 960,
            child: modulesAsync.when(
              loading: () => const LoadingIndicator(),
              error: (e, _) => ErrorView(message: e.toString()),
              data: (modules) => _ModulesList(
                courseId: courseId,
                modules: modules,
                onRefresh: () {
                  ref.invalidate(courseModulesProvider(courseId));
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addModule(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Module'),
      ),
    );
  }

  Future<void> _addModule(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Module'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Module title'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (title == null || title.isEmpty) return;

    final modules = await ref.read(courseModulesProvider(courseId).future);
    await ref.read(courseRepositoryProvider).createModule(
          courseId: courseId,
          title: title,
          sortOrder: modules.length,
        );
    ref.invalidate(courseModulesProvider(courseId));
  }
}

class _ModulesList extends ConsumerStatefulWidget {
  const _ModulesList({
    required this.courseId,
    required this.modules,
    required this.onRefresh,
  });

  final String courseId;
  final List<CourseModule> modules;
  final VoidCallback onRefresh;

  @override
  ConsumerState<_ModulesList> createState() => _ModulesListState();
}

class _ModulesListState extends ConsumerState<_ModulesList> {
  final _expanded = <String, bool>{};

  @override
  Widget build(BuildContext context) {
    if (widget.modules.isEmpty) {
      return const Center(
        child: Text('No modules yet. Tap "Add Module" to start.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.modules.length,
      itemBuilder: (context, index) {
        final module = widget.modules[index];
        final isExpanded = _expanded[module.id] ?? true;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              ListTile(
                title: Text('Unit ${index + 1}: ${module.title}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                      onPressed: () => setState(
                        () => _expanded[module.id] = !isExpanded,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteModule(module.id),
                    ),
                  ],
                ),
              ),
              if (isExpanded)
                _LessonsSection(
                  courseId: widget.courseId,
                  moduleId: module.id,
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteModule(String moduleId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete module?'),
        content: const Text('All lessons in this module will be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(courseRepositoryProvider).deleteModule(moduleId);
    widget.onRefresh();
  }
}

class _LessonsSection extends ConsumerWidget {
  const _LessonsSection({required this.courseId, required this.moduleId});

  final String courseId;
  final String moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Lesson>>(
      future: ref.read(courseRepositoryProvider).getLessons(moduleId),
      builder: (context, snapshot) {
        final lessons = snapshot.data ?? [];

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              ...lessons.map(
                (lesson) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.play_lesson_outlined, size: 20),
                  title: Text(lesson.title),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => context.push(
                    RouteNames.instructorLessonEdit(courseId, lesson.id),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _addLesson(context, ref, lessons.length),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Lesson'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addLesson(
    BuildContext context,
    WidgetRef ref,
    int sortOrder,
  ) async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Lesson'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Lesson title'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (title == null || title.isEmpty) return;

    final lesson = await ref.read(courseRepositoryProvider).createLesson(
          moduleId: moduleId,
          title: title,
          sortOrder: sortOrder,
        );

    if (context.mounted) {
      context.push(RouteNames.instructorLessonEdit(courseId, lesson.id));
    }
  }
}
