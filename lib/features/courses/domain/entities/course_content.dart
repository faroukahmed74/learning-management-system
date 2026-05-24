import 'package:equatable/equatable.dart';

import '../../../../shared/domain/enums/material_type.dart';

class CourseModule extends Equatable {
  const CourseModule({
    required this.id,
    required this.courseId,
    required this.title,
    required this.sortOrder,
    this.description,
  });

  final String id;
  final String courseId;
  final String title;
  final String? description;
  final int sortOrder;

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, courseId, title, sortOrder];
}

class Lesson extends Equatable {
  const Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.sortOrder,
    this.description,
    this.durationMinutes,
    this.isFreePreview = false,
  });

  final String id;
  final String moduleId;
  final String title;
  final String? description;
  final int sortOrder;
  final int? durationMinutes;
  final bool isFreePreview;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      moduleId: json['module_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      durationMinutes: json['duration_minutes'] as int?,
      isFreePreview: json['is_free_preview'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, moduleId, title, sortOrder];
}

class LessonMaterial extends Equatable {
  const LessonMaterial({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.title,
    required this.sortOrder,
    this.storagePath,
    this.externalUrl,
    this.fileName,
    this.mimeType,
    this.fileSizeBytes,
    this.durationSeconds,
  });

  final String id;
  final String lessonId;
  final MaterialType type;
  final String title;
  final String? storagePath;
  final String? externalUrl;
  final String? fileName;
  final String? mimeType;
  final int? fileSizeBytes;
  final int? durationSeconds;
  final int sortOrder;

  factory LessonMaterial.fromJson(Map<String, dynamic> json) {
    return LessonMaterial(
      id: json['id'] as String,
      lessonId: json['lesson_id'] as String,
      type: MaterialType.values.firstWhere(
        (t) => t.name == (json['type'] as String),
        orElse: () => MaterialType.document,
      ),
      title: json['title'] as String,
      storagePath: json['storage_path'] as String?,
      externalUrl: json['external_url'] as String?,
      fileName: json['file_name'] as String?,
      mimeType: json['mime_type'] as String?,
      fileSizeBytes: json['file_size_bytes'] as int?,
      durationSeconds: json['duration_seconds'] as int?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, lessonId, type, title];
}
