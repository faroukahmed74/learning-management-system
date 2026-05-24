import 'package:flutter_test/flutter_test.dart';
import 'package:learning_management_system/core/utils/storage_path.dart';

void main() {
  group('materialStoragePath', () {
    test('uses ASCII key for Arabic filenames', () {
      expect(
        materialStoragePath(
          courseId: 'course-id',
          lessonId: 'lesson-id',
          materialId: 'material-id',
          originalFileName: 'وثيقه التامين.pdf',
        ),
        'course-id/lesson-id/material-id/file.pdf',
      );
    });

    test('preserves safe extension from dotted names', () {
      expect(
        safeStorageExtension('notes.final.pdf'),
        'pdf',
      );
    });

    test('falls back to bin when extension is missing or unsafe', () {
      expect(safeStorageExtension('README'), 'bin');
      expect(safeStorageExtension('file.'), 'bin');
      expect(safeStorageExtension('file.bad ext'), 'bin');
    });
  });
}
