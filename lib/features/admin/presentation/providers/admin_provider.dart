import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.fetchDashboardStats();
});

final adminUsersProvider = FutureProvider<List<AdminUserRow>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.fetchUsers();
});

final adminCentersProvider = FutureProvider<List<AdminCenterRow>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.fetchCenters();
});
