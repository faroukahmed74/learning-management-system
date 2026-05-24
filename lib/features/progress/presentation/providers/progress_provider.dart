import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/progress_repository.dart';
import '../../domain/entities/lesson_progress.dart';

export '../../domain/entities/lesson_progress.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository();
});

final lessonProgressProvider =
    FutureProvider.family<LessonProgressRecord?, String>((ref, lessonId) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return null;
  return ref.watch(progressRepositoryProvider).getLessonProgress(user.id, lessonId);
});

final courseProgressSummaryProvider =
    FutureProvider.family<CourseProgressSummary, String>((ref, courseId) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    return const CourseProgressSummary(completedLessons: 0, totalLessons: 0);
  }
  return ref.watch(progressRepositoryProvider).getCourseProgress(user.id, courseId);
});

final courseLessonProgressMapProvider =
    FutureProvider.family<Map<String, LessonProgressRecord>, String>((ref, courseId) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return {};
  return ref.watch(progressRepositoryProvider).getCourseLessonProgressMap(user.id, courseId);
});
