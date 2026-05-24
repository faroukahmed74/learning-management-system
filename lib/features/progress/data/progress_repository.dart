import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/supabase_client.dart';
import '../domain/entities/lesson_progress.dart';

class ProgressRepository {
  ProgressRepository({SupabaseClient? client}) : _client = client ?? supabaseClient;

  final SupabaseClient? _client;

  SupabaseClient get _db {
    final client = _client;
    if (client == null) throw const AppException('Supabase is not configured');
    return client;
  }

  Future<LessonProgressRecord?> getLessonProgress(
    String studentId,
    String lessonId,
  ) async {
    final row = await _db
        .from('lesson_progress')
        .select()
        .eq('student_id', studentId)
        .eq('lesson_id', lessonId)
        .maybeSingle();
    if (row == null) return null;
    return LessonProgressRecord.fromJson(Map<String, dynamic>.from(row));
  }

  Future<LessonProgressRecord> upsertProgress({
    required String studentId,
    required String lessonId,
    required int videoPositionSeconds,
    required int completionPercentage,
  }) async {
    final row = await _db
        .from('lesson_progress')
        .upsert({
          'student_id': studentId,
          'lesson_id': lessonId,
          'video_position_seconds': videoPositionSeconds,
          'completion_percentage': completionPercentage,
        }, onConflict: 'student_id,lesson_id')
        .select()
        .single();
    return LessonProgressRecord.fromJson(Map<String, dynamic>.from(row));
  }

  Future<CourseProgressSummary> getCourseProgress(
    String studentId,
    String courseId,
  ) async {
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
    if (lessonIds.isEmpty) {
      return const CourseProgressSummary(completedLessons: 0, totalLessons: 0);
    }

    final progress = await _db
        .from('lesson_progress')
        .select('status')
        .eq('student_id', studentId)
        .inFilter('lesson_id', lessonIds);

    final completed = (progress as List).where((r) => r['status'] == 'completed').length;
    return CourseProgressSummary(
      completedLessons: completed,
      totalLessons: lessonIds.length,
    );
  }

  Future<Map<String, LessonProgressRecord>> getCourseLessonProgressMap(
    String studentId,
    String courseId,
  ) async {
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
    if (lessonIds.isEmpty) return {};

    final rows = await _db
        .from('lesson_progress')
        .select()
        .eq('student_id', studentId)
        .inFilter('lesson_id', lessonIds);

    final map = <String, LessonProgressRecord>{};
    for (final row in rows as List) {
      final record = LessonProgressRecord.fromJson(Map<String, dynamic>.from(row));
      map[record.lessonId] = record;
    }
    return map;
  }
}
