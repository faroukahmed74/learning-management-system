import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/course_content.dart';
import '../../domain/entities/course.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/course_repository.dart';

export '../../domain/entities/course_content.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepository();
});

final instructorCoursesProvider = FutureProvider<List<Course>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return [];

  final repo = ref.watch(courseRepositoryProvider);
  return repo.getInstructorCourses(user.id);
});

final publishedCoursesProvider = FutureProvider<List<Course>>((ref) async {
  final repo = ref.watch(courseRepositoryProvider);
  return repo.getPublishedCourses();
});

final courseDetailProvider =
    FutureProvider.family<Course?, String>((ref, courseId) async {
  final repo = ref.watch(courseRepositoryProvider);
  return repo.getCourseById(courseId);
});

final courseModulesProvider =
    FutureProvider.family<List<CourseModule>, String>((ref, courseId) async {
  final repo = ref.watch(courseRepositoryProvider);
  return repo.getModules(courseId);
});

final lessonDetailProvider =
    FutureProvider.family<Lesson?, String>((ref, lessonId) async {
  final repo = ref.watch(courseRepositoryProvider);
  return repo.getLessonById(lessonId);
});

final lessonMaterialsProvider =
    FutureProvider.family<List<LessonMaterial>, String>((ref, lessonId) async {
  final repo = ref.watch(courseRepositoryProvider);
  return repo.getMaterials(lessonId);
});
