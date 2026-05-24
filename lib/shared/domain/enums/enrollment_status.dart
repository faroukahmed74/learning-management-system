enum EnrollmentStatus {
  active,
  completed,
  dropped,
  suspended;

  String get label => switch (this) {
        EnrollmentStatus.active => 'Active',
        EnrollmentStatus.completed => 'Completed',
        EnrollmentStatus.dropped => 'Dropped',
        EnrollmentStatus.suspended => 'Suspended',
      };

  static EnrollmentStatus fromString(String? value) {
    return EnrollmentStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => EnrollmentStatus.active,
    );
  }
}
