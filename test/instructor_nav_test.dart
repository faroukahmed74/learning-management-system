import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/core/router/route_names.dart';
import 'package:learning_management_system/core/router/route_guards.dart';
import 'package:learning_management_system/l10n/app_localizations.dart';
import 'package:learning_management_system/shared/domain/enums/user_role.dart';
import 'package:learning_management_system/shared/widgets/role_adaptive_shell.dart';
import 'package:learning_management_system/features/instructor/presentation/screens/instructor_dashboard_screen.dart';

void main() {
  testWidgets('flat instructor routes navigate to courses and batches', (tester) async {
    final l10n = AppLocalizations(const Locale('en'));
    final shellItems = InstructorDashboardScreen.shellItems(l10n);

    final router = GoRouter(
      initialLocation: RouteNames.instructorDashboard,
      redirect: (context, state) => resolveRouteRedirect(
        location: state.uri.path,
        envConfigured: true,
        hasSession: true,
        role: UserRole.instructor,
      ),
      routes: [
        GoRoute(
          path: '/instructor',
          redirect: (_, __) => RouteNames.instructorDashboard,
        ),
        GoRoute(
          path: RouteNames.instructorDashboard,
          builder: (_, __) => RoleAdaptiveShell(
            role: UserRole.instructor,
            title: 'Dashboard',
            items: shellItems,
            child: const Text('Dashboard Body'),
          ),
        ),
        GoRoute(
          path: RouteNames.instructorCourses,
          builder: (_, __) => RoleAdaptiveShell(
            role: UserRole.instructor,
            title: 'Courses',
            items: shellItems,
            child: const Text('Courses Body'),
          ),
        ),
        GoRoute(
          path: RouteNames.instructorBatches,
          builder: (_, __) => RoleAdaptiveShell(
            role: UserRole.instructor,
            title: 'Batches',
            items: shellItems,
            child: const Text('Batches Body'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Dashboard Body'), findsOneWidget);

    await tester.tap(find.text('Courses'));
    await tester.pumpAndSettle();
    expect(find.text('Courses Body'), findsOneWidget);

    await tester.tap(find.text('Batches'));
    await tester.pumpAndSettle();
    expect(find.text('Batches Body'), findsOneWidget);
  });
}
