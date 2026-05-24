import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/responsive_breakpoints.dart';
import '../../core/settings/settings_provider.dart';
import '../../l10n/app_localizations.dart';

/// Responsive theme + language controls for all screens.
class AppSettingsControls extends ConsumerWidget {
  const AppSettingsControls({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = context.l10n;
    final isWide = ResponsiveBreakpoints.isDesktop(context);

    if (isWide && !compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeModeChip(
            mode: settings.themeMode,
            l10n: l10n,
            onChanged: (mode) =>
                ref.read(settingsProvider.notifier).setThemeMode(mode),
          ),
          const SizedBox(width: 8),
          _LanguageToggle(
            locale: settings.locale,
            l10n: l10n,
            onToggle: () => ref.read(settingsProvider.notifier).toggleLocale(),
          ),
        ],
      );
    }

    return IconButton(
      tooltip: l10n.settings,
      icon: const Icon(Icons.tune),
      onPressed: () => _showSettingsSheet(context, ref),
    );
  }

  void _showSettingsSheet(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: isMobile,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Consumer(
              builder: (context, ref, _) {
                final current = ref.watch(settingsProvider);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.settings, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 20),
                    Text(l10n.theme, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text(l10n.themeLight),
                          icon: const Icon(Icons.light_mode_outlined),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text(l10n.themeDark),
                          icon: const Icon(Icons.dark_mode_outlined),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text(l10n.themeSystem),
                          icon: const Icon(Icons.settings_brightness_outlined),
                        ),
                      ],
                      selected: {current.themeMode},
                      onSelectionChanged: (selection) {
                        ref.read(settingsProvider.notifier).setThemeMode(selection.first);
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(l10n.language, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment(value: 'en', label: Text(l10n.english)),
                        ButtonSegment(value: 'ar', label: Text(l10n.arabic)),
                      ],
                      selected: {current.locale.languageCode},
                      onSelectionChanged: (selection) {
                        ref.read(settingsProvider.notifier).setLocale(
                              Locale(selection.first),
                            );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _ThemeModeChip extends StatelessWidget {
  const _ThemeModeChip({
    required this.mode,
    required this.l10n,
    required this.onChanged,
  });

  final ThemeMode mode;
  final AppLocalizations l10n;
  final ValueChanged<ThemeMode> onChanged;

  IconData get _icon => switch (mode) {
        ThemeMode.light => Icons.light_mode_outlined,
        ThemeMode.dark => Icons.dark_mode_outlined,
        ThemeMode.system => Icons.settings_brightness_outlined,
      };

  String get _label => switch (mode) {
        ThemeMode.light => l10n.themeLight,
        ThemeMode.dark => l10n.themeDark,
        ThemeMode.system => l10n.themeSystem,
      };

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(_icon, size: 18),
      label: Text(_label),
      onPressed: () {
        final next = switch (mode) {
          ThemeMode.system => ThemeMode.light,
          ThemeMode.light => ThemeMode.dark,
          ThemeMode.dark => ThemeMode.system,
        };
        onChanged(next);
      },
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({
    required this.locale,
    required this.l10n,
    required this.onToggle,
  });

  final Locale locale;
  final AppLocalizations l10n;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isArabic = locale.languageCode == 'ar';
    return ActionChip(
      avatar: const Icon(Icons.language, size: 18),
      label: Text(isArabic ? l10n.arabic : l10n.english),
      onPressed: onToggle,
    );
  }
}
