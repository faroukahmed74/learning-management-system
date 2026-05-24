import 'package:equatable/equatable.dart';

import '../../../../shared/domain/enums/enrollment_status.dart';
import '../../../courses/domain/entities/course.dart';

class Enrollment extends Equatable {
  const Enrollment({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.status,
    required this.enrolledAt,
    this.batchId,
    this.course,
    this.progressPercent,
  });

  final String id;
  final String studentId;
  final String courseId;
  final String? batchId;
  final EnrollmentStatus status;
  final DateTime enrolledAt;
  final Course? course;
  final int? progressPercent;

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    final courseJson = json['courses'];
    return Enrollment(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      courseId: json['course_id'] as String,
      batchId: json['batch_id'] as String?,
      status: EnrollmentStatus.fromString(json['status'] as String?),
      enrolledAt: DateTime.parse(json['enrolled_at'] as String),
      course: courseJson is Map<String, dynamic>
          ? Course.fromJson(courseJson)
          : null,
      progressPercent: json['progress_percent'] as int?,
    );
  }

  @override
  List<Object?> get props => [id, studentId, courseId];
}
