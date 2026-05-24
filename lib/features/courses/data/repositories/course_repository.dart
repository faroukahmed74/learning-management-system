import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/utils/slug.dart';
import '../../../../shared/domain/enums/cefr_level.dart';
import '../../../../shared/domain/enums/course_status.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/course_content.dart';

class CourseRepository {
  CourseRepository({SupabaseClient? client}) : _client = client ?? supabaseClient;

  final SupabaseClient? _client;

  SupabaseClient get _db {
    final client = _client;
    if (client == null) {
      throw const AppException('Supabase is not configured');
    }
    return client;
  }

  Future<List<Course>> getInstructorCourses(String instructorId) async {
    final rows = await _db
        .from('courses')
        .select()
        .eq('instructor_id', instructorId)
        .order('created_at', ascending: false);

    return (rows as List)
        .map((row) => Course.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<List<Course>> getPublishedCourses() async {
    final rows = await _db
        .from('courses')
        .select()
        .eq('status', CourseStatus.published.name)
        .order('created_at', ascending: false);

    return (rows as List)
        .map((row) => Course.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<Course?> getCourseById(String id) async {
    final row = await _db.from('courses').select().eq('id', id).maybeSingle();
    if (row == null) return null;
    return Course.fromJson(Map<String, dynamic>.from(row));
  }

  Future<Course> createCourse({
    required String title,
    required String languageTaught,
    required CefrLevel level,
    required String instructorId,
    String? description,
  }) async {
    final baseSlug = slugify(title);
    final slug = uniqueSlug(baseSlug.isEmpty ? 'course' : baseSlug);

    final row = await _db
        .from('courses')
        .insert({
          'title': title,
          'slug': slug,
          'language_taught': languageTaught,
          'level': level.label,
          'instructor_id': instructorId,
          if (description != null && description.isNotEmpty)
            'description': description,
          'status': CourseStatus.draft.name,
        })
        .select()
        .single();

    return Course.fromJson(Map<String, dynamic>.from(row));
  }

  Future<Course> updateCourse(Course course) async {
    final row = await _db
        .from('courses')
        .update({
          'title': course.title,
          'description': course.description,
          'language_taught': course.languageTaught,
          'level': course.level.label,
          'status': course.status.name,
          if (course.durationWeeks != null) 'duration_weeks': course.durationWeeks,
          if (course.maxStudents != null) 'max_students': course.maxStudents,
          if (course.status == CourseStatus.published && course.publishedAt == null)
            'published_at': DateTime.now().toIso8601String(),
        })
        .eq('id', course.id)
        .select()
        .single();

    return Course.fromJson(Map<String, dynamic>.from(row));
  }

  Future<void> deleteCourse(String id) async {
    await _db.from('courses').delete().eq('id', id);
  }

  Future<List<CourseModule>> getModules(String courseId) async {
    final rows = await _db
        .from('course_modules')
        .select()
        .eq('course_id', courseId)
        .order('sort_order');

    return (rows as List)
        .map((row) => CourseModule.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<CourseModule> createModule({
    required String courseId,
    required String title,
    required int sortOrder,
  }) async {
    final row = await _db
        .from('course_modules')
        .insert({
          'course_id': courseId,
          'title': title,
          'sort_order': sortOrder,
        })
        .select()
        .single();

    return CourseModule.fromJson(Map<String, dynamic>.from(row));
  }

  Future<void> deleteModule(String moduleId) async {
    await _db.from('course_modules').delete().eq('id', moduleId);
  }

  Future<List<Lesson>> getLessons(String moduleId) async {
    final rows = await _db
        .from('lessons')
        .select()
        .eq('module_id', moduleId)
        .order('sort_order');

    return (rows as List)
        .map((row) => Lesson.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<Lesson> createLesson({
    required String moduleId,
    required String title,
    required int sortOrder,
  }) async {
    final row = await _db
        .from('lessons')
        .insert({
          'module_id': moduleId,
          'title': title,
          'sort_order': sortOrder,
        })
        .select()
        .single();

    return Lesson.fromJson(Map<String, dynamic>.from(row));
  }

  Future<Lesson?> getLessonById(String lessonId) async {
    final row = await _db.from('lessons').select().eq('id', lessonId).maybeSingle();
    if (row == null) return null;
    return Lesson.fromJson(Map<String, dynamic>.from(row));
  }

  Future<void> deleteLesson(String lessonId) async {
    await _db.from('lessons').delete().eq('id', lessonId);
  }

  Future<List<LessonMaterial>> getMaterials(String lessonId) async {
    final rows = await _db
        .from('lesson_materials')
        .select()
        .eq('lesson_id', lessonId)
        .order('sort_order');

    return (rows as List)
        .map((row) => LessonMaterial.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<LessonMaterial> createMaterial({
    required String lessonId,
    required String title,
    required String type,
    String? storagePath,
    String? externalUrl,
    String? fileName,
    String? mimeType,
    int? fileSizeBytes,
    int sortOrder = 0,
  }) async {
    final row = await _db
        .from('lesson_materials')
        .insert({
          'lesson_id': lessonId,
          'title': title,
          'type': type,
          if (storagePath != null) 'storage_path': storagePath,
          if (externalUrl != null) 'external_url': externalUrl,
          if (fileName != null) 'file_name': fileName,
          if (mimeType != null) 'mime_type': mimeType,
          if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
          'sort_order': sortOrder,
        })
        .select()
        .single();

    return LessonMaterial.fromJson(Map<String, dynamic>.from(row));
  }

  Future<LessonMaterial> updateMaterial({
    required String materialId,
    String? storagePath,
    String? externalUrl,
  }) async {
    final row = await _db
        .from('lesson_materials')
        .update({
          if (storagePath != null) 'storage_path': storagePath,
          if (externalUrl != null) 'external_url': externalUrl,
        })
        .eq('id', materialId)
        .select()
        .single();

    return LessonMaterial.fromJson(Map<String, dynamic>.from(row));
  }

  Future<void> deleteMaterial(String materialId) async {
    await _db.from('lesson_materials').delete().eq('id', materialId);
  }
}