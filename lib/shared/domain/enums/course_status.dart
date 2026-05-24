enum CourseStatus {
  draft,
  published,
  archived;

  String get label => switch (this) {
        CourseStatus.draft => 'Draft',
        CourseStatus.published => 'Published',
        CourseStatus.archived => 'Archived',
      };
}
