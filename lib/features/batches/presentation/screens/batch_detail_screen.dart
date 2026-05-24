import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/router/route_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../shared/widgets/app_settings_controls.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../enrollments/presentation/providers/enrollments_provider.dart';
import '../providers/batches_provider.dart';

class BatchDetailScreen extends ConsumerWidget {
  const BatchDetailScreen({super.key, required this.batchId});

  final String batchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final batchAsync = ref.watch(batchDetailProvider(batchId));

    return batchAsync.when(
      loading: () => Scaffold(body: LoadingIndicator(message: l10n.loading)),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.batch),
          actions: const [AppSettingsControls(compact: true)],
        ),
        body: ErrorView(error: e),
      ),
      data: (batch) {
        if (batch == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.batch),
              actions: const [AppSettingsControls(compact: true)],
            ),
            body: Center(child: Text(l10n.batchNotFound)),
          );
        }

        final rosterAsync = ref.watch(
          batchRosterProvider((batchId: batchId, courseId: batch.courseId)),
        );
        final sessionsAsync = ref.watch(batchSessionsProvider(batchId));

        return Scaffold(
          appBar: AppBar(
            title: Text(batch.name),
            actions: [
              const AppSettingsControls(compact: true),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    context.push(RouteNames.instructorBatchEdit(batchId)),
              ),
            ],
          ),
          body: ResponsiveContent(
            maxWidth: 960,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Card(
                  child: ListTile(
                    title: Text(batch.courseTitle ?? l10n.course),
                    subtitle: Text(
                      [
                        if (batch.startDate != null)
                          '${l10n.startLabel}: ${batch.startDate!.toString().split(' ').first}',
                        if (batch.endDate != null)
                          '${l10n.endLabel}: ${batch.endDate!.toString().split(' ').first}',
                        batch.isActive ? l10n.active : l10n.inactive,
                      ].join(' · '),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(l10n.students, style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => _addStudent(context, ref, batch.courseId),
                      icon: const Icon(Icons.person_add, size: 18),
                      label: Text(l10n.addStudent),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                rosterAsync.when(
                  loading: () => LoadingIndicator(message: l10n.loading),
                  error: (e, _) => Text(l10n.friendlyError(e)),
                  data: (roster) {
                    if (roster.isEmpty) {
                      return EmptyState(
                        title: l10n.noStudents,
                        subtitle: l10n.addStudentsHint,
                        icon: Icons.people_outline,
                      );
                    }
                    return Column(
                      children: roster
                          .map(
                            (entry) => Card(
                              child: ListTile(
                                title: Text(entry.studentName),
                                subtitle: Text(entry.studentEmail),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${entry.progressPercent}%'),
                                    IconButton(
                                      icon: const Icon(Icons.person_remove_outlined),
                                      onPressed: () async {
                                        await ref
                                            .read(enrollmentRepositoryProvider)
                                            .removeEnrollment(entry.enrollmentId);
                                        ref.invalidate(
                                          batchRosterProvider(
                                            (
                                              batchId: batchId,
                                              courseId: batch.courseId,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      l10n.liveSessions,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => _scheduleSession(context, ref, batch),
                      icon: const Icon(Icons.video_call, size: 18),
                      label: Text(l10n.schedule),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                sessionsAsync.when(
                  loading: () => LoadingIndicator(message: l10n.loading),
                  error: (e, _) => Text(l10n.friendlyError(e)),
                  data: (sessions) {
                    if (sessions.isEmpty) {
                      return EmptyState(
                        title: l10n.noSessions,
                        subtitle: l10n.scheduleSessionHint,
                        icon: Icons.video_call_outlined,
                      );
                    }
                    return Column(
                      children: sessions
                          .map(
                            (s) => _SessionTile(
                              session: s,
                              onDelete: () async {
                                await ref
                                    .read(batchRepositoryProvider)
                                    .deleteSession(s.id);
                                ref.invalidate(batchSessionsProvider(batchId));
                              },
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addStudent(
    BuildContext context,
    WidgetRef ref,
    String courseId,
  ) async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    List<Map<String, dynamic>> results = [];

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.addStudent),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(labelText: l10n.searchStudent),
                  onChanged: (q) async {
                    if (q.length < 2) return;
                    results = await ref
                        .read(enrollmentRepositoryProvider)
                        .searchStudents(q);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                ...results.map(
                  (student) => ListTile(
                    title: Text(student['full_name'] as String? ?? ''),
                    subtitle: Text(student['email'] as String? ?? ''),
                    onTap: () async {
                      await ref
                          .read(enrollmentRepositoryProvider)
                          .assignStudentToBatch(
                            studentId: student['id'] as String,
                            courseId: courseId,
                            batchId: batchId,
                          );
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ],
        ),
      ),
    );

    ref.invalidate(batchRosterProvider((batchId: batchId, courseId: courseId)));
  }

  Future<void> _scheduleSession(
    BuildContext context,
    WidgetRef ref,
    batch,
  ) async {
    final l10n = context.l10n;
    final titleController = TextEditingController();
    final urlController = TextEditingController(text: 'https://meet.google.com/');
    final start = DateTime.now().add(const Duration(days: 1));
    final end = start.add(const Duration(hours: 1));

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.scheduleLiveSession),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: l10n.title),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: urlController,
              decoration: InputDecoration(labelText: l10n.meetingUrl),
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

    if (confirmed != true || titleController.text.trim().isEmpty) return;

    final user = await ref.read(currentUserProvider.future);
    if (user == null) return;

    await ref.read(batchRepositoryProvider).createSession(
          LiveSession(
            id: '',
            courseId: batch.courseId,
            batchId: batchId,
            instructorId: user.id,
            title: titleController.text.trim(),
            startTime: start,
            endTime: end,
            meetingUrl: urlController.text.trim(),
          ),
        );
    ref.invalidate(batchSessionsProvider(batchId));
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session, required this.onDelete});

  final LiveSession session;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.video_call),
        title: Text(session.title),
        subtitle: Text(session.startTime.toLocal().toString().split('.').first),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () => launchUrl(Uri.parse(session.meetingUrl)),
            ),
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
