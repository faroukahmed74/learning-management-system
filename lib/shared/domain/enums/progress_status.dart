enum ProgressStatus {
  notStarted,
  inProgress,
  completed;

  String get dbValue => switch (this) {
        ProgressStatus.notStarted => 'not_started',
        ProgressStatus.inProgress => 'in_progress',
        ProgressStatus.completed => 'completed',
      };

  static ProgressStatus fromString(String? value) {
    return switch (value) {
      'in_progress' => ProgressStatus.inProgress,
      'completed' => ProgressStatus.completed,
      _ => ProgressStatus.notStarted,
    };
  }
}
