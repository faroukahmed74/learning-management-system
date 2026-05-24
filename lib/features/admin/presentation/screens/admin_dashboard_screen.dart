import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/responsive_breakpoints.dart';
import '../../../../core/router/route_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/domain/enums/user_role.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../../../shared/widgets/role_adaptive_shell.dart';
import '../providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  static List<ShellDestination> shellItems(AppLocalizations l10n) => [
        ShellDestination(
          route: RouteNames.adminDashboard,
          destination: NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
        ),
        ShellDestination(
          route: RouteNames.adminUsers,
          destination: NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: l10n.users,
          ),
        ),
        ShellDestination(
          route: RouteNames.adminCenters,
          destination: NavigationDestination(
            icon: const Icon(Icons.location_city_outlined),
            selectedIcon: const Icon(Icons.location_city),
            label: l10n.centers,
          ),
        ),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final statsAsync = ref.watch(adminStatsProvider);

    return RoleAdaptiveShell(
      role: UserRole.admin,
      title: l10n.adminDashboard,
      items: shellItems(l10n),
      child: statsAsync.when(
        loading: () => LoadingIndicator(message: l10n.loadingStats),
        error: (error, _) => ErrorView(
          error: error,
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
                title: l10n.students,
                value: '${stats.totalStudents}',
                icon: Icons.school,
              ),
              _StatCard(
                title: l10n.instructors,
                value: '${stats.totalInstructors}',
                icon: Icons.person,
              ),
              _StatCard(
                title: l10n.activeCourses,
                value: '${stats.activeCourses}',
                icon: Icons.menu_book,
              ),
              _StatCard(
                title: l10n.enrollments7d,
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
    final l10n = context.l10n;
    final usersAsync = ref.watch(adminUsersProvider);

    return RoleAdaptiveShell(
      role: UserRole.admin,
      title: l10n.users,
      items: AdminDashboardScreen.shellItems(l10n),
      child: usersAsync.when(
        loading: () => LoadingIndicator(message: l10n.loadingUsers),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(adminUsersProvider),
        ),
        data: (users) {
          if (users.isEmpty) {
            return EmptyState(
              title: l10n.noUsersYet,
              subtitle: l10n.usersWillAppear,
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
                      leading: CircleAvatar(
                        child: Text(
                          user.fullName.isNotEmpty
                              ? user.fullName[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(user.fullName),
                      subtitle: Text(
                        '${user.email} · ${_roleLabel(user.role, l10n)}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (role) async {
                          await ref
                              .read(adminRepositoryProvider)
                              .updateUserRole(user.id, role);
                          ref.invalidate(adminUsersProvider);
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'student',
                            child: Text(l10n.setStudent),
                          ),
                          PopupMenuItem(
                            value: 'instructor',
                            child: Text(l10n.setInstructor),
                          ),
                          PopupMenuItem(
                            value: 'admin',
                            child: Text(l10n.setAdmin),
                          ),
                        ],
                        child: Chip(label: Text(user.status)),
                      ),
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
    final l10n = context.l10n;
    final centersAsync = ref.watch(adminCentersProvider);

    return RoleAdaptiveShell(
      role: UserRole.admin,
      title: l10n.centers,
      items: AdminDashboardScreen.shellItems(l10n),
      child: Stack(
        children: [
          centersAsync.when(
            loading: () => LoadingIndicator(message: l10n.loadingCenters),
            error: (error, _) => ErrorView(
              error: error,
              onRetry: () => ref.invalidate(adminCentersProvider),
            ),
            data: (centers) {
              if (centers.isEmpty) {
                return EmptyState(
                  title: l10n.noCentersYet,
                  subtitle: l10n.addCenterOrSeed,
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
                          label: Text(
                            center.isActive ? l10n.active : l10n.inactive,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: () => _addCenter(context, ref),
              icon: const Icon(Icons.add),
              label: Text(l10n.addCenter),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addCenter(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final nameController = TextEditingController();
    final slugController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.newCenter),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: l10n.name),
            ),
            TextField(
              controller: slugController,
              decoration: InputDecoration(labelText: l10n.slug),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(adminRepositoryProvider).createCenter(
          name: nameController.text.trim(),
          slug: slugController.text.trim(),
        );
    ref.invalidate(adminCentersProvider);
  }
}

String _roleLabel(String role, AppLocalizations l10n) => switch (role) {
      'admin' => l10n.roleAdmin,
      'instructor' => l10n.roleInstructor,
      _ => l10n.roleStudent,
    };
