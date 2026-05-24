import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/route_names.dart';
import '../../../../shared/domain/enums/user_role.dart';
import '../../../../core/constants/responsive_breakpoints.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/role_adaptive_shell.dart';
import '../providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  static const shellItems = [
    ShellDestination(
      route: RouteNames.adminDashboard,
      destination: NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
    ),
    ShellDestination(
      route: RouteNames.adminUsers,
      destination: NavigationDestination(
        icon: Icon(Icons.people_outline),
        selectedIcon: Icon(Icons.people),
        label: 'Users',
      ),
    ),
    ShellDestination(
      route: RouteNames.adminCenters,
      destination: NavigationDestination(
        icon: Icon(Icons.location_city_outlined),
        selectedIcon: Icon(Icons.location_city),
        label: 'Centers',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return RoleAdaptiveShell(
      role: UserRole.admin,
      title: 'Admin Dashboard',
      items: shellItems,
      child: statsAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading stats...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(adminStatsProvider),
        ),
        data: (stats) => ResponsiveContent(
          maxWidth: 1200,
          padding: const EdgeInsets.all(24),
          child: GridView.count(
            crossAxisCount: ResponsiveBreakpoints.gridColumns(
              context,
              mobile: 1,
              tablet: 2,
              desktop: 4,
            ),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8,
            children: [
              _StatCard(
                title: 'Students',
                value: '${stats.totalStudents}',
                icon: Icons.school,
              ),
              _StatCard(
                title: 'Instructors',
                value: '${stats.totalInstructors}',
                icon: Icons.person,
              ),
              _StatCard(
                title: 'Active Courses',
                value: '${stats.activeCourses}',
                icon: Icons.menu_book,
              ),
              _StatCard(
                title: 'Enrollments (7d)',
                value: '${stats.enrollments7d}',
                icon: Icons.trending_up,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const Spacer(),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            Text(title),
          ],
        ),
      ),
    );
  }
}

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);

    return RoleAdaptiveShell(
      role: UserRole.admin,
      title: 'Users',
      items: AdminDashboardScreen.shellItems,
      child: usersAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading users...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(adminUsersProvider),
        ),
        data: (users) {
          if (users.isEmpty) {
            return const EmptyState(
              title: 'No users yet',
              subtitle: 'Registered users will appear here.',
              icon: Icons.people_outline,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminUsersProvider),
            child: ResponsiveContent(
              child: ListView.separated(
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?')),
                      title: Text(user.fullName),
                      subtitle: Text('${user.email} · ${user.role}'),
                      trailing: Chip(label: Text(user.status)),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class AdminCentersScreen extends ConsumerWidget {
  const AdminCentersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final centersAsync = ref.watch(adminCentersProvider);

    return RoleAdaptiveShell(
      role: UserRole.admin,
      title: 'Centers',
      items: AdminDashboardScreen.shellItems,
      child: centersAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading centers...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(adminCentersProvider),
        ),
        data: (centers) {
          if (centers.isEmpty) {
            return const EmptyState(
              title: 'No centers yet',
              subtitle: 'Run supabase/seed.sql to add a default center.',
              icon: Icons.location_city_outlined,
            );
          }

          return ResponsiveContent(
            child: ListView.separated(
              itemCount: centers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final center = centers[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_city),
                    title: Text(center.name),
                    subtitle: Text(center.slug),
                    trailing: Chip(
                      label: Text(center.isActive ? 'Active' : 'Inactive'),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
