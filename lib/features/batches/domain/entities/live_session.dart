import 'package:equatable/equatable.dart';

class LiveSession extends Equatable {
  const LiveSession({
    required this.id,
    required this.courseId,
    required this.instructorId,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.meetingUrl,
    this.batchId,
    this.description,
  });

  final String id;
  final String courseId;
  final String? batchId;
  final String instructorId;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String meetingUrl;

  factory LiveSession.fromJson(Map<String, dynamic> json) {
    return LiveSession(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      batchId: json['batch_id'] as String?,
      instructorId: json['instructor_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      meetingUrl: json['meeting_url'] as String,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'course_id': courseId,
      'instructor_id': instructorId,
      'title': title,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
      'meeting_url': meetingUrl,
      if (batchId != null) 'batch_id': batchId,
      if (description != null && description!.isNotEmpty) 'description': description,
    };
  }

  @override
  List<Object?> get props => [id, title, startTime];
}
