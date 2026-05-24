import 'package:flutter_test/flutter_test.dart';
import 'package:learning_management_system/core/router/route_guards.dart';
import 'package:learning_management_system/core/router/route_names.dart';
import 'package:learning_management_system/shared/domain/enums/user_role.dart';

void main() {
  group('resolveRouteRedirect', () {
    test('unconfigured env redirects to login', () {
      expect(
        resolveRouteRedirect(
          location: RouteNames.studentDashboard,
          envConfigured: false,
          hasSession: false,
          role: null,
        ),
        RouteNames.login,
      );
    });

    test('guest on protected route redirects to login', () {
      expect(
        resolveRouteRedirect(
          location: RouteNames.adminDashboard,
          envConfigured: true,
          hasSession: false,
          role: null,
        ),
        RouteNames.login,
      );
    });

    test('guest on auth routes is allowed', () {
      expect(
        resolveRouteRedirect(
          location: RouteNames.login,
          envConfigured: true,
          hasSession: false,
          role: null,
        ),
        isNull,
      );
    });

    test('authenticated user on login redirects to role home', () {
      expect(
        resolveRouteRedirect(
          location: RouteNames.login,
          envConfigured: true,
          hasSession: true,
          role: UserRole.instructor,
        ),
        RouteNames.instructorDashboard,
      );
    });

    test('student cannot access admin routes', () {
      expect(
        resolveRouteRedirect(
          location: RouteNames.adminUsers,
          envConfigured: true,
          hasSession: true,
          role: UserRole.student,
        ),
        RouteNames.studentDashboard,
      );
    });

    test('instructor cannot access student routes', () {
      expect(
        resolveRouteRedirect(
          location: RouteNames.studentCatalog,
          envConfigured: true,
          hasSession: true,
          role: UserRole.instructor,
        ),
        RouteNames.instructorDashboard,
      );
    });

    test('admin can access all role sections', () {
      for (final route in [
        RouteNames.adminDashboard,
        RouteNames.instructorCourses,
        RouteNames.studentCatalog,
        RouteNames.profile,
      ]) {
        expect(
          resolveRouteRedirect(
            location: route,
            envConfigured: true,
            hasSession: true,
            role: UserRole.admin,
          ),
          isNull,
          reason: 'admin should access $route',
        );
      }
    });

    test('all roles can access profile and notifications', () {
      for (final role in UserRole.values) {
        for (final route in [RouteNames.profile, RouteNames.notifications]) {
          expect(
            resolveRouteRedirect(
              location: route,
              envConfigured: true,
              hasSession: true,
              role: role,
            ),
            isNull,
            reason: '$role should access $route',
          );
        }
      }
    });
  });

  group('homeRouteForRole', () {
    test('maps each role to its dashboard', () {
      expect(homeRouteForRole(UserRole.admin), RouteNames.adminDashboard);
      expect(homeRouteForRole(UserRole.instructor), RouteNames.instructorDashboard);
      expect(homeRouteForRole(UserRole.student), RouteNames.studentDashboard);
    });
  });

  group('sectionRootRedirect', () {
    test('redirects section root to dashboard', () {
      expect(
        sectionRootRedirect('/admin', RouteNames.adminDashboard, '/admin'),
        RouteNames.adminDashboard,
      );
    });

    test('allows nested paths', () {
      expect(
        sectionRootRedirect(
          '/instructor',
          RouteNames.instructorDashboard,
          '/instructor/courses/new',
        ),
        isNull,
      );
    });
  });
}
