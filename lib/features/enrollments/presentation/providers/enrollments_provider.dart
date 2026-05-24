import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/enrollment_repository.dart';
import '../../domain/entities/enrollment.dart';

export '../../domain/entities/enrollment.dart';

final enrollmentRepositoryProvider = Provider<EnrollmentRepository>((ref) {
  return EnrollmentRepository();
});

final studentEnrollmentsProvider = FutureProvider<List<Enrollment>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return [];
  return ref.watch(enrollmentRepositoryProvider).getStudentEnrollments(user.id);
});

final isEnrolledProvider = FutureProvider.family<bool, String>((ref, courseId) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return false;
  return ref.watch(enrollmentRepositoryProvider).isEnrolled(user.id, courseId);
});
