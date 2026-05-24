import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../courses/presentation/providers/courses_provider.dart';
import '../../data/batch_repository.dart';
import '../../domain/entities/batch.dart';
import '../../domain/entities/batch_roster_entry.dart';
import '../../domain/entities/live_session.dart';

export '../../domain/entities/batch.dart';
export '../../domain/entities/live_session.dart';
export '../../domain/entities/batch_roster_entry.dart';

final batchRepositoryProvider = Provider<BatchRepository>((ref) {
  return BatchRepository();
});

final instructorBatchesProvider = FutureProvider<List<CourseBatch>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return [];
  return ref.watch(batchRepositoryProvider).getInstructorBatches(user.id);
});

final batchDetailProvider = FutureProvider.family<CourseBatch?, String>((ref, batchId) {
  return ref.watch(batchRepositoryProvider).getBatchById(batchId);
});

final batchRosterProvider =
    FutureProvider.family<List<BatchRosterEntry>, ({String batchId, String courseId})>(
  (ref, params) {
    return ref.watch(batchRepositoryProvider).getBatchRoster(
          params.batchId,
          params.courseId,
        );
  },
);

final batchSessionsProvider = FutureProvider.family<List<LiveSession>, String>((ref, batchId) {
  return ref.watch(batchRepositoryProvider).getBatchSessions(batchId);
});

final instructorCoursesForBatchProvider = FutureProvider<List<Course>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return [];
  return ref.watch(courseRepositoryProvider).getInstructorCourses(user.id);
});
