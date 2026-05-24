import 'package:equatable/equatable.dart';

import '../../../../shared/domain/enums/cefr_level.dart';
import '../../../../shared/domain/enums/course_status.dart';

class Course extends Equatable {
  const Course({
    required this.id,
    required this.title,
    required this.slug,
    required this.languageTaught,
    required this.level,
    required this.instructorId,
    required this.status,
    this.description,
    this.thumbnailUrl,
    this.centerId,
    this.durationWeeks,
    this.maxStudents,
    this.publishedAt,
    this.createdAt,
  });

  final String id;
  final String title;
  final String slug;
  final String? description;
  final String languageTaught;
  final CefrLevel level;
  final String? thumbnailUrl;
  final String instructorId;
  final String? centerId;
  final CourseStatus status;
  final int? durationWeeks;
  final int? maxStudents;
  final DateTime? publishedAt;
  final DateTime? createdAt;

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      languageTaught: json['language_taught'] as String,
      level: CefrLevel.fromString(json['level'] as String?) ?? CefrLevel.a1,
      thumbnailUrl: json['thumbnail_url'] as String?,
      instructorId: json['instructor_id'] as String,
      centerId: json['center_id'] as String?,
      status: CourseStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String? ?? 'draft'),
        orElse: () => CourseStatus.draft,
      ),
      durationWeeks: json['duration_weeks'] as int?,
      maxStudents: json['max_students'] as int?,
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'title': title,
      'slug': slug,
      if (description != null) 'description': description,
      'language_taught': languageTaught,
      'level': level.label,
      'instructor_id': instructorId,
      if (centerId != null) 'center_id': centerId,
      'status': status.name,
      if (durationWeeks != null) 'duration_weeks': durationWeeks,
      if (maxStudents != null) 'max_students': maxStudents,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (publishedAt != null) 'published_at': publishedAt!.toIso8601String(),
    };
  }

  Course copyWith({
    String? title,
    String? slug,
    String? description,
    String? languageTaught,
    CefrLevel? level,
    CourseStatus? status,
    int? durationWeeks,
    int? maxStudents,
    DateTime? publishedAt,
  }) {
    return Course(
      id: id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      languageTaught: languageTaught ?? this.languageTaught,
      level: level ?? this.level,
      instructorId: instructorId,
      centerId: centerId,
      status: status ?? this.status,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      maxStudents: maxStudents ?? this.maxStudents,
      thumbnailUrl: thumbnailUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, slug, status, instructorId];
}
