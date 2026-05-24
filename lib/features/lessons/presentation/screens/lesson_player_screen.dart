import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../courses/presentation/providers/courses_provider.dart';
import '../../../lessons/presentation/providers/lessons_provider.dart';
import '../../../lessons/presentation/widgets/document_viewer_widget.dart';
import '../../../lessons/presentation/widgets/video_player_widget.dart';
import '../../../../shared/domain/enums/material_type.dart' as lms;
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/responsive_content.dart';

class LessonPlayerScreen extends ConsumerWidget {
  const LessonPlayerScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  final String courseId;
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonAsync = ref.watch(lessonDetailProvider(lessonId));
    final materialsAsync = ref.watch(lessonMaterialsProvider(lessonId));

    return lessonAsync.when(
      loading: () => const Scaffold(
        body: LoadingIndicator(message: 'Loading lesson...'),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Lesson')),
        body: ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(lessonDetailProvider(lessonId)),
        ),
      ),
      data: (lesson) {
        if (lesson == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Lesson')),
            body: const Center(child: Text('Lesson not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(lesson.title)),
          body: materialsAsync.when(
            loading: () => const LoadingIndicator(message: 'Loading lesson...'),
            error: (e, _) => ErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(lessonMaterialsProvider(lessonId)),
            ),
            data: (materials) {
              if (materials.isEmpty) {
                return const ResponsiveContent(
                  child: EmptyState(
                    title: 'No content yet',
                    subtitle: 'This lesson has no materials uploaded.',
                    icon: Icons.play_lesson_outlined,
                  ),
                );
              }

              return ResponsiveContent(
                maxWidth: 960,
                child: ListView(
                  children: materials.map((material) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _MaterialPlayer(material: material),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _MaterialPlayer extends ConsumerWidget {
  const _MaterialPlayer({required this.material});

  final LessonMaterial material;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (material.storagePath == null && material.externalUrl != null) {
      return ListTile(
        title: Text(material.title),
        subtitle: Text(material.type.label),
        trailing: const Icon(Icons.open_in_new),
      );
    }

    if (material.storagePath == null) {
      return ListTile(title: Text(material.title));
    }

    final urlAsync = ref.watch(materialSignedUrlProvider(material.storagePath!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(material.title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        urlAsync.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) => Text('Error: $e'),
          data: (url) {
            if (material.type == lms.MaterialType.video) {
              return VideoPlayerWidget(url: url);
            }
            if (material.type == lms.MaterialType.document) {
              return DocumentViewerWidget(url: url);
            }
            return ListTile(
              title: Text(material.type.label),
              subtitle: Text(material.fileName ?? ''),
            );
          },
        ),
      ],
    );
  }
}
