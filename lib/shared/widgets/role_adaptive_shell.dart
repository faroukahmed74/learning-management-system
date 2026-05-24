import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/responsive_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/domain/enums/user_role.dart';
import 'app_settings_controls.dart';

class ShellDestination {
  const ShellDestination({
    required this.route,
    required this.destination,
  });

  final String route;
  final NavigationDestination destination;
}

class RoleAdaptiveShell extends StatelessWidget {
  const RoleAdaptiveShell({
    super.key,
    required this.role,
    required this.title,
    required this.items,
    required this.child,
    this.selectedIndex,
  });

  final UserRole role;
  final String title;
  final List<ShellDestination> items;
  final Widget child;
  final int? selectedIndex;

  int _resolveSelectedIndex(BuildContext context) {
    if (selectedIndex != null) return selectedIndex!;

    final location = GoRouterState.of(context).uri.path;
    for (var i = items.length - 1; i >= 0; i--) {
      final route = items[i].route;
      if (location == route || location.startsWith('$route/')) {
        return i;
      }
    }
    return 0;
  }

  Color get _accent => switch (role) {
        UserRole.admin => AppColors.adminAccent,
        UserRole.instructor => AppColors.instructorAccent,
        UserRole.student => AppColors.studentAccent,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final width = MediaQuery.sizeOf(context).width;
    final useRail = width >= ResponsiveBreakpoints.mobile;
    final useExtendedRail = width >= ResponsiveBreakpoints.tablet;
    final activeIndex = _resolveSelectedIndex(context);

    void onSelect(int index) => context.go(items[index].route);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: _accent.withValues(alpha: 0.08),
        actions: [
          const AppSettingsControls(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
            tooltip: l10n.notifications,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
            tooltip: l10n.profile,
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (useRail)
            NavigationRail(
              extended: useExtendedRail,
              selectedIndex: activeIndex,
              onDestinationSelected: onSelect,
              labelType: useExtendedRail
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              destinations: items
                  .map(
                    (item) => NavigationRailDestination(
                      icon: item.destination.icon,
                      selectedIcon:
                          item.destination.selectedIcon ?? item.destination.icon,
                      label: Text(item.destination.label),
                    ),
                  )
                  .toList(),
            ),
          Expanded(
            child: useRail
                ? child
                : SafeArea(
                    bottom: false,
                    child: child,
                  ),
          ),
        ],
      ),
      bottomNavigationBar: useRail
          ? null
          : NavigationBar(
              selectedIndex: activeIndex,
              onDestinationSelected: onSelect,
              destinations: items.map((item) => item.destination).toList(),
            ),
    );
  }
}
