import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/domain/enums/material_type.dart' as lms;
import '../../../../shared/domain/enums/progress_status.dart';
import '../../../../shared/widgets/app_settings_controls.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../courses/presentation/providers/courses_provider.dart';
import '../../../progress/presentation/providers/progress_provider.dart';
import '../providers/lessons_provider.dart';
import '../widgets/document_viewer_widget.dart';
import '../widgets/video_player_widget.dart';

class LessonPlayerScreen extends ConsumerStatefulWidget {
  const LessonPlayerScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  final String courseId;
  final String lessonId;

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  int _lastSavedAt = 0;

  Future<void> _saveProgress(int position, int duration) async {
    if (duration <= 0) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastSavedAt < 5000 && position < duration * 0.9) return;
    _lastSavedAt = now;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final percent = ((position / duration) * 100).clamp(0, 100).round();
    await ref.read(progressRepositoryProvider).upsertProgress(
          studentId: user.id,
          lessonId: widget.lessonId,
          videoPositionSeconds: position,
          completionPercentage: percent,
        );
    ref.invalidate(lessonProgressProvider(widget.lessonId));
    ref.invalidate(courseProgressSummaryProvider(widget.courseId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lessonAsync = ref.watch(lessonDetailProvider(widget.lessonId));
    final materialsAsync = ref.watch(lessonMaterialsProvider(widget.lessonId));
    final progressAsync = ref.watch(lessonProgressProvider(widget.lessonId));

    return lessonAsync.when(
      loading: () => Scaffold(
        body: LoadingIndicator(message: l10n.loadingLesson),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.lesson),
          actions: const [AppSettingsControls(compact: true)],
        ),
        body: ErrorView(error: e),
      ),
      data: (lesson) {
        if (lesson == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.lesson),
              actions: const [AppSettingsControls(compact: true)],
            ),
            body: Center(child: Text(l10n.lessonNotFound)),
          );
        }

        final initialPosition =
            progressAsync.valueOrNull?.videoPositionSeconds ?? 0;

        return Scaffold(
          appBar: AppBar(
            title: Text(lesson.title),
            actions: [
              const AppSettingsControls(compact: true),
              if (progressAsync.valueOrNull?.status == ProgressStatus.completed)
                const Padding(
                  padding: EdgeInsetsDirectional.only(end: 12),
                  child: Icon(Icons.check_circle, color: Colors.green),
                ),
            ],
          ),
          body: materialsAsync.when(
            loading: () => LoadingIndicator(message: l10n.loadingLesson),
            error: (e, _) => ErrorView(
              error: e,
              onRetry: () =>
                  ref.invalidate(lessonMaterialsProvider(widget.lessonId)),
            ),
            data: (materials) {
              if (materials.isEmpty) {
                return ResponsiveContent(
                  child: EmptyState(
                    title: l10n.noContentYet,
                    subtitle: l10n.noMaterialsUploaded,
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
                      child: _MaterialPlayer(
                        material: material,
                        initialPositionSeconds: initialPosition,
                        onProgress: _saveProgress,
                        l10n: l10n,
                      ),
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
  const _MaterialPlayer({
    required this.material,
    required this.initialPositionSeconds,
    required this.onProgress,
    required this.l10n,
  });

  final LessonMaterial material;
  final int initialPositionSeconds;
  final void Function(int position, int duration) onProgress;
  final AppLocalizations l10n;

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
          loading: () => LoadingIndicator(message: l10n.loading),
          error: (e, _) => Text(l10n.couldNotLoadVideo),
          data: (url) {
            if (material.type == lms.MaterialType.video) {
              return VideoPlayerWidget(
                url: url,
                initialPositionSeconds: initialPositionSeconds,
                onProgress: onProgress,
              );
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
