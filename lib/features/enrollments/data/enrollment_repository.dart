import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/supabase_client.dart';
import '../domain/entities/enrollment.dart';

class EnrollmentRepository {
  EnrollmentRepository({SupabaseClient? client}) : _client = client ?? supabaseClient;

  final SupabaseClient? _client;

  SupabaseClient get _db {
    final client = _client;
    if (client == null) throw const AppException('Supabase is not configured');
    return client;
  }

  Future<bool> isEnrolled(String studentId, String courseId) async {
    final row = await _db
        .from('enrollments')
        .select('id')
        .eq('student_id', studentId)
        .eq('course_id', courseId)
        .eq('status', 'active')
        .maybeSingle();
    return row != null;
  }

  Future<Enrollment> enrollStudent({
    required String studentId,
    required String courseId,
    String? batchId,
  }) async {
    final row = await _db
        .from('enrollments')
        .insert({
          'student_id': studentId,
          'course_id': courseId,
          if (batchId != null) 'batch_id': batchId,
          'status': 'active',
        })
        .select()
        .single();
    return Enrollment.fromJson(Map<String, dynamic>.from(row));
  }

  Future<List<Enrollment>> getStudentEnrollments(String studentId) async {
    final rows = await _db
        .from('enrollments')
        .select('*, courses(*)')
        .eq('student_id', studentId)
        .eq('status', 'active')
        .order('enrolled_at', ascending: false);

    final enrollments = <Enrollment>[];
    for (final row in rows as List) {
      final map = Map<String, dynamic>.from(row);
      final courseId = map['course_id'] as String;
      final progress = await _progressPercent(studentId, courseId);
      map['progress_percent'] = progress;
      enrollments.add(Enrollment.fromJson(map));
    }
    return enrollments;
  }

  Future<List<Map<String, dynamic>>> searchStudents(String query) async {
    final rows = await _db
        .from('profiles')
        .select('id, full_name, email')
        .eq('role', 'student')
        .or('full_name.ilike.%$query%,email.ilike.%$query%')
        .limit(20);

    return (rows as List).map((r) => Map<String, dynamic>.from(r)).toList();
  }

  Future<void> assignStudentToBatch({
    required String studentId,
    required String courseId,
    required String batchId,
  }) async {
    final existing = await _db
        .from('enrollments')
        .select('id')
        .eq('student_id', studentId)
        .eq('course_id', courseId)
        .maybeSingle();

    if (existing != null) {
      await _db
          .from('enrollments')
          .update({'batch_id': batchId, 'status': 'active'})
          .eq('id', existing['id']);
    } else {
      await enrollStudent(
        studentId: studentId,
        courseId: courseId,
        batchId: batchId,
      );
    }
  }

  Future<void> removeEnrollment(String enrollmentId) async {
    await _db.from('enrollments').delete().eq('id', enrollmentId);
  }

  Future<int> _progressPercent(String studentId, String courseId) async {
    final modules = await _db
        .from('course_modules')
        .select('lessons(id)')
        .eq('course_id', courseId);

    final lessonIds = <String>[];
    for (final module in modules as List) {
      for (final lesson in (module['lessons'] as List? ?? [])) {
        lessonIds.add(lesson['id'] as String);
      }
    }
    if (lessonIds.isEmpty) return 0;

    final progress = await _db
        .from('lesson_progress')
        .select('status')
        .eq('student_id', studentId)
        .inFilter('lesson_id', lessonIds);

    final completed = (progress as List).where((r) => r['status'] == 'completed').length;
    return ((completed / lessonIds.length) * 100).round();
  }
}
