import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_settings_controls.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../courses/domain/entities/course.dart';
import '../providers/batches_provider.dart';
import '../../../../shared/widgets/app_feedback.dart';

class BatchFormScreen extends ConsumerStatefulWidget {
  const BatchFormScreen({super.key, this.batchId});

  final String? batchId;

  @override
  ConsumerState<BatchFormScreen> createState() => _BatchFormScreenState();
}

class _BatchFormScreenState extends ConsumerState<BatchFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _maxStudentsController = TextEditingController();

  Course? _selectedCourse;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;
  bool _saving = false;
  CourseBatch? _existing;

  bool get isEditing => widget.batchId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) _loadBatch();
  }

  Future<void> _loadBatch() async {
    final batch = await ref.read(batchDetailProvider(widget.batchId!).future);
    if (batch == null || !mounted) return;
    final courses = await ref.read(instructorCoursesForBatchProvider.future);
    setState(() {
      _existing = batch;
      _nameController.text = batch.name;
      _startDate = batch.startDate;
      _endDate = batch.endDate;
      _isActive = batch.isActive;
      if (batch.maxStudents != null) {
        _maxStudentsController.text = '${batch.maxStudents}';
      }
      for (final course in courses) {
        if (course.id == batch.courseId) {
          _selectedCourse = course;
          break;
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _maxStudentsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate() || _selectedCourse == null) {
      if (_selectedCourse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.selectCourse)),
        );
      }
      return;
    }

    setState(() => _saving = true);
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw Exception(l10n.notSignedIn);

      final batch = CourseBatch(
        id: _existing?.id ?? '',
        courseId: _selectedCourse!.id,
        instructorId: user.id,
        name: _nameController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        maxStudents: int.tryParse(_maxStudentsController.text.trim()),
        isActive: _isActive,
      );

      final repo = ref.read(batchRepositoryProvider);
      if (isEditing) {
        await repo.updateBatch(widget.batchId!, batch);
        ref.invalidate(batchDetailProvider(widget.batchId!));
      } else {
        final created = await repo.createBatch(batch);
        ref.invalidate(instructorBatchesProvider);
        if (mounted) {
          context.go(RouteNames.instructorBatchDetail(created.id));
          return;
        }
      }
      ref.invalidate(instructorBatchesProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final coursesAsync = ref.watch(instructorCoursesForBatchProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editBatch : l10n.newBatchTitle),
        actions: [
          const AppSettingsControls(compact: true),
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.save),
          ),
        ],
      ),
      body: coursesAsync.when(
        loading: () => Center(child: Text(l10n.loading)),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (courses) {
          if (courses.isEmpty) {
            return Center(child: Text(l10n.createCourseFirst));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<Course>(
                    initialValue: _selectedCourse,
                    decoration: InputDecoration(labelText: l10n.course),
                    items: courses
                        .map(
                          (c) => DropdownMenuItem<Course>(
                            value: c,
                            child: Text(c.title),
                          ),
                        )
                        .toList(),
                    onChanged: (c) => setState(() => _selectedCourse = c),
                    validator: (v) =>
                        v == null ? l10n.fieldRequired(l10n.course) : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: l10n.batchName),
                    validator: (v) => v == null || v.trim().length < 2
                        ? l10n.minChars(2)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _maxStudentsController,
                    decoration: InputDecoration(labelText: l10n.maxStudents),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.startDate),
                    subtitle: Text(
                      _startDate?.toString().split(' ').first ?? l10n.notSet,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _pickDate(true),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.endDate),
                    subtitle: Text(
                      _endDate?.toString().split(' ').first ?? l10n.notSet,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _pickDate(false),
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.active),
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
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
