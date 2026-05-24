import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/network/supabase_client.dart';

class AdminStats {
  const AdminStats({
    required this.totalStudents,
    required this.totalInstructors,
    required this.activeCourses,
    required this.enrollments7d,
  });

  final int totalStudents;
  final int totalInstructors;
  final int activeCourses;
  final int enrollments7d;

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalStudents: _asInt(json['total_students']),
      totalInstructors: _asInt(json['total_instructors']),
      activeCourses: _asInt(json['active_courses']),
      enrollments7d: _asInt(json['enrollments_7d']),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }
}

class AdminUserRow {
  const AdminUserRow({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.status,
  });

  final String id;
  final String fullName;
  final String email;
  final String role;
  final String status;

  factory AdminUserRow.fromJson(Map<String, dynamic> json) {
    return AdminUserRow(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'student',
      status: json['status'] as String? ?? 'active',
    );
  }
}

class AdminCenterRow {
  const AdminCenterRow({
    required this.id,
    required this.name,
    required this.slug,
    required this.isActive,
  });

  final String id;
  final String name;
  final String slug;
  final bool isActive;

  factory AdminCenterRow.fromJson(Map<String, dynamic> json) {
    return AdminCenterRow(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class AdminRepository {
  AdminRepository({SupabaseClient? client}) : _client = client ?? supabaseClient;

  final SupabaseClient? _client;

  SupabaseClient get _db {
    final client = _client;
    if (client == null) {
      throw const AppException('Supabase is not configured');
    }
    return client;
  }

  Future<AdminStats> fetchDashboardStats() async {
    final row = await _db.from('admin_dashboard_stats').select().maybeSingle();
    if (row == null) {
      return const AdminStats(
        totalStudents: 0,
        totalInstructors: 0,
        activeCourses: 0,
        enrollments7d: 0,
      );
    }
    return AdminStats.fromJson(Map<String, dynamic>.from(row));
  }

  Future<List<AdminUserRow>> fetchUsers() async {
    final rows = await _db
        .from('profiles')
        .select('id, full_name, email, role, status')
        .order('created_at', ascending: false);

    return (rows as List)
        .map((row) => AdminUserRow.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<List<AdminCenterRow>> fetchCenters() async {
    final rows = await _db
        .from('centers')
        .select('id, name, slug, is_active')
        .order('name');

    return (rows as List)
        .map((row) => AdminCenterRow.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }
}
