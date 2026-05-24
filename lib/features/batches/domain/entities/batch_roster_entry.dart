import 'package:equatable/equatable.dart';

class BatchRosterEntry extends Equatable {
  const BatchRosterEntry({
    required this.enrollmentId,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.progressPercent,
    required this.enrolledAt,
  });

  final String enrollmentId;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final int progressPercent;
  final DateTime enrolledAt;

  @override
  List<Object?> get props => [enrollmentId, studentId];
}
