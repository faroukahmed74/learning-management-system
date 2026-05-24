import 'package:equatable/equatable.dart';

class CourseBatch extends Equatable {
  const CourseBatch({
    required this.id,
    required this.courseId,
    required this.instructorId,
    required this.name,
    this.startDate,
    this.endDate,
    this.maxStudents,
    this.isActive = true,
    this.courseTitle,
    this.enrollmentCount,
  });

  final String id;
  final String courseId;
  final String instructorId;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? maxStudents;
  final bool isActive;
  final String? courseTitle;
  final int? enrollmentCount;

  factory CourseBatch.fromJson(Map<String, dynamic> json) {
    return CourseBatch(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      instructorId: json['instructor_id'] as String,
      name: json['name'] as String,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      maxStudents: json['max_students'] as int?,
      isActive: json['is_active'] as bool? ?? true,
      courseTitle: json['course_title'] as String?,
      enrollmentCount: json['enrollment_count'] as int?,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'course_id': courseId,
      'instructor_id': instructorId,
      'name': name,
      if (startDate != null) 'start_date': startDate!.toIso8601String().split('T').first,
      if (endDate != null) 'end_date': endDate!.toIso8601String().split('T').first,
      if (maxStudents != null) 'max_students': maxStudents,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [id, courseId, name];
}
