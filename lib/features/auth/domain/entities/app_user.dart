import 'package:equatable/equatable.dart';

import '../../../../shared/domain/enums/user_role.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    this.phone,
    this.bio,
    this.nativeLanguage,
    this.targetLanguage,
  });

  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? avatarUrl;
  final String? phone;
  final String? bio;
  final String? nativeLanguage;
  final String? targetLanguage;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'User',
      role: UserRole.fromString(json['role'] as String? ?? 'student'),
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
      nativeLanguage: json['native_language'] as String?,
      targetLanguage: json['target_language'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [id, email, fullName, role, avatarUrl, phone, bio, nativeLanguage, targetLanguage];
}
