import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/supabase_client.dart';
import '../domain/entities/batch.dart';
import '../domain/entities/batch_roster_entry.dart';
import '../domain/entities/live_session.dart';

class BatchRepository {
  BatchRepository({SupabaseClient? client}) : _client = client ?? supabaseClient;

  final SupabaseClient? _client;

  SupabaseClient get _db {
    final client = _client;
    if (client == null) throw const AppException('Supabase is not configured');
    return client;
  }

  Future<List<CourseBatch>> getInstructorBatches(String instructorId) async {
    final rows = await _db
        .from('batches')
        .select('*, courses(title)')
        .eq('instructor_id', instructorId)
        .order('created_at', ascending: false);

    return (rows as List).map((row) {
      final map = Map<String, dynamic>.from(row);
      final course = map.remove('courses');
      if (course is Map) map['course_title'] = course['title'];
      return CourseBatch.fromJson(map);
    }).toList();
  }

  Future<CourseBatch?> getBatchById(String batchId) async {
    final row = await _db
        .from('batches')
        .select('*, courses(title)')
        .eq('id', batchId)
        .maybeSingle();
    if (row == null) return null;
    final map = Map<String, dynamic>.from(row);
    final course = map.remove('courses');
    if (course is Map) map['course_title'] = course['title'];
    return CourseBatch.fromJson(map);
  }

  Future<CourseBatch> createBatch(CourseBatch batch) async {
    final row = await _db
        .from('batches')
        .insert(batch.toInsertJson())
        .select()
        .single();
    return CourseBatch.fromJson(Map<String, dynamic>.from(row));
  }

  Future<CourseBatch> updateBatch(String id, CourseBatch batch) async {
    final row = await _db
        .from('batches')
        .update(batch.toInsertJson())
        .eq('id', id)
        .select()
        .single();
    return CourseBatch.fromJson(Map<String, dynamic>.from(row));
  }

  Future<void> deleteBatch(String id) async {
    await _db.from('batches').delete().eq('id', id);
  }

  Future<List<BatchRosterEntry>> getBatchRoster(String batchId, String courseId) async {
    final rows = await _db
        .from('enrollments')
        .select('id, student_id, enrolled_at, profiles(full_name, email)')
        .eq('batch_id', batchId)
        .order('enrolled_at', ascending: false);

    final entries = <BatchRosterEntry>[];
    for (final row in rows as List) {
      final map = Map<String, dynamic>.from(row);
      final profile = map['profiles'] as Map<String, dynamic>?;
      final studentId = map['student_id'] as String;
      final progress = await _courseProgressPercent(studentId, courseId);
      entries.add(BatchRosterEntry(
        enrollmentId: map['id'] as String,
        studentId: studentId,
        studentName: profile?['full_name'] as String? ?? 'Student',
        studentEmail: profile?['email'] as String? ?? '',
        progressPercent: progress,
        enrolledAt: DateTime.parse(map['enrolled_at'] as String),
      ));
    }
    return entries;
  }

  Future<int> _courseProgressPercent(String studentId, String courseId) async {
    final lessonRows = await _db
        .from('course_modules')
        .select('lessons(id)')
        .eq('course_id', courseId);

    final lessonIds = <String>[];
    for (final module in lessonRows as List) {
      final lessons = module['lessons'] as List?;
      if (lessons == null) continue;
      for (final lesson in lessons) {
        lessonIds.add(lesson['id'] as String);
      }
    }
    if (lessonIds.isEmpty) return 0;

    final progressRows = await _db
        .from('lesson_progress')
        .select('status')
        .eq('student_id', studentId)
        .inFilter('lesson_id', lessonIds);

    final completed = (progressRows as List)
        .where((r) => r['status'] == 'completed')
        .length;
    return ((completed / lessonIds.length) * 100).round();
  }

  Future<List<LiveSession>> getBatchSessions(String batchId) async {
    final rows = await _db
        .from('live_sessions')
        .select()
        .eq('batch_id', batchId)
        .order('start_time', ascending: false);

    return (rows as List)
        .map((row) => LiveSession.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<LiveSession> createSession(LiveSession session) async {
    final row = await _db
        .from('live_sessions')
        .insert(session.toInsertJson())
        .select()
        .single();
    return LiveSession.fromJson(Map<String, dynamic>.from(row));
  }

  Future<void> deleteSession(String sessionId) async {
    await _db.from('live_sessions').delete().eq('id', sessionId);
  }
}
