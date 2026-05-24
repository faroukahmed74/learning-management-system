import 'package:equatable/equatable.dart';

import '../../../../shared/domain/enums/progress_status.dart';

class LessonProgressRecord extends Equatable {
  const LessonProgressRecord({
    required this.id,
    required this.studentId,
    required this.lessonId,
    required this.status,
    required this.videoPositionSeconds,
    required this.completionPercentage,
    this.lastAccessedAt,
  });

  final String id;
  final String studentId;
  final String lessonId;
  final ProgressStatus status;
  final int videoPositionSeconds;
  final int completionPercentage;
  final DateTime? lastAccessedAt;

  factory LessonProgressRecord.fromJson(Map<String, dynamic> json) {
    return LessonProgressRecord(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      lessonId: json['lesson_id'] as String,
      status: ProgressStatus.fromString(json['status'] as String?),
      videoPositionSeconds: json['video_position_seconds'] as int? ?? 0,
      completionPercentage: json['completion_percentage'] as int? ?? 0,
      lastAccessedAt: json['last_accessed_at'] != null
          ? DateTime.parse(json['last_accessed_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, lessonId, status];
}

class CourseProgressSummary extends Equatable {
  const CourseProgressSummary({
    required this.completedLessons,
    required this.totalLessons,
  });

  final int completedLessons;
  final int totalLessons;

  int get percent =>
      totalLessons == 0 ? 0 : ((completedLessons / totalLessons) * 100).round();

  @override
  List<Object?> get props => [completedLessons, totalLessons];
}
