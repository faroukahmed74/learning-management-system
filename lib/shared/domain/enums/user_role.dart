enum UserRole {
  admin,
  instructor,
  student;

  String get label => switch (this) {
        UserRole.admin => 'Admin',
        UserRole.instructor => 'Instructor',
        UserRole.student => 'Student',
      };

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.student,
    );
  }
}
