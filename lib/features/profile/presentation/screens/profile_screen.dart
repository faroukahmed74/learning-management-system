import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_settings_controls.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          const AppSettingsControls(compact: true),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push(RouteNames.profileEdit),
            tooltip: l10n.editProfile,
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => Center(child: Text(l10n.loading)),
        error: (error, _) => ErrorView(error: error),
        data: (user) {
          if (user == null) {
            return Center(child: Text(l10n.notSignedIn));
          }

          return ResponsiveContent(
            maxWidth: 480,
            child: ListView(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Text(
                            user.fullName.isNotEmpty
                                ? user.fullName[0].toUpperCase()
                                : '?',
                            style: Theme.of(context).textTheme.headlineMedium,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(user.fullName, style: Theme.of(context).textTheme.titleLarge),
                Text(user.email),
                if (user.phone != null && user.phone!.isNotEmpty) Text(user.phone!),
                const SizedBox(height: 8),
                Chip(label: Text(user.role.localizedLabel(l10n))),
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(user.bio!),
                ],
                if (user.nativeLanguage != null || user.targetLanguage != null) ...[
                  const SizedBox(height: 16),
                  if (user.nativeLanguage != null)
                    Text('${l10n.nativeLabel}: ${user.nativeLanguage}'),
                  if (user.targetLanguage != null)
                    Text('${l10n.learningLabel}: ${user.targetLanguage}'),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (context.mounted) context.go(RouteNames.login);
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.signOut),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
