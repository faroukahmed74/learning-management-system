import '../../shared/domain/enums/user_role.dart';
import 'route_names.dart';

/// Returns a redirect path, or null if navigation is allowed.
String? resolveRouteRedirect({
  required String location,
  required bool envConfigured,
  required bool hasSession,
  required UserRole? role,
}) {
  final isAuthRoute = location == RouteNames.login ||
      location == RouteNames.register ||
      location == RouteNames.forgotPassword;

  if (!envConfigured && location != RouteNames.login) {
    return RouteNames.login;
  }

  if (!hasSession) {
    return isAuthRoute ? null : RouteNames.login;
  }

  if (isAuthRoute || location == RouteNames.splash) {
    if (role != null) return homeRouteForRole(role);
    return RouteNames.studentDashboard;
  }

  if (role == null) return null;

  // Shared authenticated routes — all roles
  if (location == RouteNames.profile || location == RouteNames.notifications) {
    return null;
  }

  // Admin can access all sections (for management & preview)
  if (role == UserRole.admin) return null;

  if (location.startsWith('/admin')) {
    return homeRouteForRole(role);
  }

  if (location.startsWith('/instructor') && role != UserRole.instructor) {
    return homeRouteForRole(role);
  }

  if (location.startsWith('/student') && role != UserRole.student) {
    return homeRouteForRole(role);
  }

  return null;
}

String homeRouteForRole(UserRole role) {
  return switch (role) {
    UserRole.admin => RouteNames.adminDashboard,
    UserRole.instructor => RouteNames.instructorDashboard,
    UserRole.student => RouteNames.studentDashboard,
  };
}

String? sectionRootRedirect(String sectionPath, String dashboardPath, String path) {
  if (path == sectionPath || path == '$sectionPath/') {
    return dashboardPath;
  }
  return null;
}
