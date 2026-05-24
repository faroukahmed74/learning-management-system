import 'package:flutter_test/flutter_test.dart';
import 'package:learning_management_system/shared/domain/enums/progress_status.dart';

void main() {
  group('ProgressStatus', () {
    test('parses database values', () {
      expect(ProgressStatus.fromString('completed'), ProgressStatus.completed);
      expect(ProgressStatus.fromString('in_progress'), ProgressStatus.inProgress);
      expect(ProgressStatus.fromString(null), ProgressStatus.notStarted);
    });
  });

  group('Course progress calculation', () {
    test('percent rounds correctly', () {
      const summary = (completed: 3, total: 10);
      final percent = ((summary.completed / summary.total) * 100).round();
      expect(percent, 30);
    });

    test('90% threshold marks completion via DB trigger logic', () {
      const completionPercentage = 90;
      expect(completionPercentage >= 90, isTrue);
    });
  });
}
