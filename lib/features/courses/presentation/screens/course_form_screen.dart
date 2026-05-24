import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/domain/enums/cefr_level.dart';
import '../../../../shared/domain/enums/course_status.dart';
import '../../../../shared/widgets/app_settings_controls.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/course.dart';
import '../providers/courses_provider.dart';

class CourseFormScreen extends ConsumerStatefulWidget {
  const CourseFormScreen({super.key, this.courseId});

  final String? courseId;

  @override
  ConsumerState<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends ConsumerState<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _languageController = TextEditingController();
  final _descriptionController = TextEditingController();

  CefrLevel _level = CefrLevel.a1;
  CourseStatus _status = CourseStatus.draft;
  bool _isSaving = false;
  Course? _existing;

  bool get isEditing => widget.courseId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadCourse();
    }
  }

  Future<void> _loadCourse() async {
    final course = await ref.read(courseDetailProvider(widget.courseId!).future);
    if (course == null || !mounted) return;

    setState(() {
      _existing = course;
      _titleController.text = course.title;
      _languageController.text = course.languageTaught;
      _descriptionController.text = course.description ?? '';
      _level = course.level;
      _status = course.status;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _languageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(courseRepositoryProvider);
      final user = await ref.read(currentUserProvider.future);

      if (user == null) throw Exception(context.l10n.notSignedIn);

      if (isEditing && _existing != null) {
        await repo.updateCourse(
          _existing!.copyWith(
            title: _titleController.text.trim(),
            languageTaught: _languageController.text.trim(),
            description: _descriptionController.text.trim(),
            level: _level,
            status: _status,
            publishedAt: _status == CourseStatus.published
                ? (_existing!.publishedAt ?? DateTime.now())
                : _existing!.publishedAt,
          ),
        );
        ref.invalidate(courseDetailProvider(widget.courseId!));
        ref.invalidate(instructorCoursesProvider);
        if (mounted) context.pop();
      } else {
        final course = await repo.createCourse(
          title: _titleController.text.trim(),
          languageTaught: _languageController.text.trim(),
          level: _level,
          instructorId: user.id,
          description: _descriptionController.text.trim(),
        );
        ref.invalidate(instructorCoursesProvider);
        if (mounted) {
          context.go(RouteNames.instructorCourseEdit(course.id));
        }
      }
    } catch (error) {
      if (mounted) showErrorSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editCourse : l10n.newCourse),
        actions: [
          const AppSettingsControls(compact: true),
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.save),
          ),
        ],
      ),
      body: ResponsiveContent(
        maxWidth: 640,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: l10n.courseTitle),
                  validator: (v) => v == null || v.trim().length < 3
                      ? l10n.minChars(3)
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _languageController,
                  decoration: InputDecoration(
                    labelText: l10n.languageTaught,
                    hintText: 'e.g. English, French',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? l10n.fieldRequired(l10n.languageTaught)
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<CefrLevel>(
                  initialValue: _level,
                  decoration: InputDecoration(labelText: l10n.cefrLevel),
                  items: CefrLevel.values
                      .map(
                        (level) => DropdownMenuItem(
                          value: level,
                          child: Text(level.label),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _level = v ?? CefrLevel.a1),
                ),
                const SizedBox(height: 16),
                if (isEditing)
                  DropdownButtonFormField<CourseStatus>(
                    initialValue: _status,
                    decoration: InputDecoration(labelText: l10n.status),
                    items: CourseStatus.values
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.label),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _status = v ?? CourseStatus.draft),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: l10n.description),
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                if (isEditing)
                  OutlinedButton.icon(
                    onPressed: () => context.go(
                      RouteNames.instructorCourseEdit(widget.courseId!),
                    ),
                    icon: const Icon(Icons.view_list),
                    label: Text(l10n.manageModulesLessons),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
