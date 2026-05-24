import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_messages.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/domain/enums/material_type.dart' as lms;
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/app_settings_controls.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../../courses/presentation/providers/courses_provider.dart';
import '../providers/lessons_provider.dart';
import '../widgets/document_viewer_widget.dart';
import '../widgets/video_player_widget.dart';

class LessonEditorScreen extends ConsumerStatefulWidget {
  const LessonEditorScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  final String courseId;
  final String lessonId;

  @override
  ConsumerState<LessonEditorScreen> createState() => _LessonEditorScreenState();
}

class _LessonEditorScreenState extends ConsumerState<LessonEditorScreen> {
  List<LessonMaterial> _materials = [];
  bool _loading = true;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    setState(() => _loading = true);
    try {
      final materials = await ref
          .read(courseRepositoryProvider)
          .getMaterials(widget.lessonId);
      setState(() => _materials = materials);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _uploadMaterial() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'mp4', 'webm', 'pdf', 'doc', 'docx', 'ppt', 'pptx',
        'mp3', 'm4a', 'jpg', 'jpeg', 'png',
      ],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    setState(() => _uploading = true);

    try {
      final storage = ref.read(storageServiceProvider);
      final repo = ref.read(courseRepositoryProvider);
      final type = storage.detectType(file);

      final material = await repo.createMaterial(
        lessonId: widget.lessonId,
        title: file.name,
        type: type.name,
        fileName: file.name,
        fileSizeBytes: file.size,
        sortOrder: _materials.length,
      );

      final path = await storage.uploadMaterial(
        courseId: widget.courseId,
        lessonId: widget.lessonId,
        materialId: material.id,
        file: file,
      );

      await repo.updateMaterial(
        materialId: material.id,
        storagePath: path,
      );

      await _loadMaterials();
    } catch (error) {
      if (mounted) showErrorSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lessonAsync = ref.watch(lessonDetailProvider(widget.lessonId));

    return lessonAsync.when(
      loading: () => Scaffold(
        body: LoadingIndicator(message: l10n.loadingLesson),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.lesson),
          actions: const [AppSettingsControls(compact: true)],
        ),
        body: ErrorView(
          error: e,
          onRetry: () => ref.invalidate(lessonDetailProvider(widget.lessonId)),
        ),
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

        return Scaffold(
          appBar: AppBar(
            title: Text(lesson.title),
            actions: const [AppSettingsControls(compact: true)],
          ),
          body: _loading
              ? LoadingIndicator(message: l10n.loading)
              : _materials.isEmpty
                  ? ResponsiveContent(
                      child: EmptyState(
                        title: l10n.noMaterials,
                        subtitle: l10n.uploadMaterialHint,
                        icon: Icons.upload_file,
                        action: FilledButton.icon(
                          onPressed: _uploading ? null : _uploadMaterial,
                          icon: _uploading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.upload),
                          label: Text(l10n.uploadMaterial),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadMaterials,
                      child: ResponsiveContent(
                        maxWidth: 960,
                        child: ListView(
                          children: [
                            ..._materials.map(
                              (m) => _MaterialTile(
                                material: m,
                                onDelete: () async {
                                  await ref
                                      .read(courseRepositoryProvider)
                                      .deleteMaterial(m.id);
                                  await _loadMaterials();
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _uploading ? null : _uploadMaterial,
                              icon: const Icon(Icons.add),
                              label: Text(
                                _uploading ? l10n.uploading : l10n.addMaterial,
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (_materials.any((m) => m.type == lms.MaterialType.video))
                              _PreviewSection(materials: _materials),
                          ],
                        ),
                      ),
                    ),
          floatingActionButton: _materials.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: _uploading ? null : _uploadMaterial,
                  icon: const Icon(Icons.upload),
                  label: Text(l10n.upload),
                )
              : null,
        );
      },
    );
  }
}

class _MaterialTile extends StatelessWidget {
  const _MaterialTile({required this.material, required this.onDelete});

  final LessonMaterial material;
  final VoidCallback onDelete;

  IconData get _icon => switch (material.type) {
        lms.MaterialType.video => Icons.videocam,
        lms.MaterialType.document => Icons.description,
        lms.MaterialType.audio => Icons.audiotrack,
        lms.MaterialType.image => Icons.image,
        lms.MaterialType.link => Icons.link,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(_icon),
        title: Text(material.title),
        subtitle: Text(
          '${material.type.label}${material.fileName != null ? ' · ${material.fileName}' : ''}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _PreviewSection extends ConsumerWidget {
  const _PreviewSection({required this.materials});

  final List<LessonMaterial> materials;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final video = materials.firstWhere(
      (m) => m.type == lms.MaterialType.video && m.storagePath != null,
      orElse: () => materials.first,
    );

    if (video.storagePath == null) return const SizedBox.shrink();

    final urlAsync = ref.watch(materialSignedUrlProvider(video.storagePath!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.preview, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        urlAsync.when(
          loading: () => LoadingIndicator(message: l10n.loading),
          error: (e, _) => Text(l10n.friendlyError(e)),
          data: (url) {
            if (video.type == lms.MaterialType.video) {
              return VideoPlayerWidget(url: url);
            }
            if (video.type == lms.MaterialType.document) {
              return DocumentViewerWidget(url: url);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
