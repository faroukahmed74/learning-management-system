import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/domain/enums/user_role.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../../../shared/widgets/role_adaptive_shell.dart';
import '../../../instructor/presentation/screens/instructor_dashboard_screen.dart';
import '../providers/batches_provider.dart';

class InstructorBatchesScreen extends ConsumerWidget {
  const InstructorBatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final batchesAsync = ref.watch(instructorBatchesProvider);

    return RoleAdaptiveShell(
      role: UserRole.instructor,
      title: l10n.batches,
      items: InstructorDashboardScreen.shellItems(l10n),
      child: Stack(
        children: [
          batchesAsync.when(
            loading: () => LoadingIndicator(message: l10n.loadingBatches),
            error: (e, _) => ErrorView(
              error: e,
              onRetry: () => ref.invalidate(instructorBatchesProvider),
            ),
            data: (batches) {
              if (batches.isEmpty) {
                return ResponsiveContent(
                  child: EmptyState(
                    title: l10n.noBatchesYet,
                    subtitle: l10n.createBatchHint,
                    icon: Icons.groups_outlined,
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(instructorBatchesProvider),
                child: ResponsiveContent(
                  child: ListView.separated(
                    itemCount: batches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final batch = batches[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.groups),
                          title: Text(batch.name),
                          subtitle: Text(
                            '${batch.courseTitle ?? l10n.course} · ${batch.isActive ? l10n.active : l10n.inactive}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () =>
                              context.push(RouteNames.instructorBatchDetail(batch.id)),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: () => context.push(RouteNames.instructorBatchNew),
              icon: const Icon(Icons.add),
              label: Text(l10n.newBatch),
            ),
          ),
        ],
      ),
    );
  }
}
