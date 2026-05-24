/// Builds Supabase-safe storage paths (ASCII only; no spaces or Unicode in keys).
String materialStoragePath({
  required String courseId,
  required String lessonId,
  required String materialId,
  required String originalFileName,
}) {
  final ext = safeStorageExtension(originalFileName);
  return '$courseId/$lessonId/$materialId/file.$ext';
}

/// Returns a lowercase alphanumeric extension, or `bin` when invalid/missing.
String safeStorageExtension(String fileName) {
  final dot = fileName.lastIndexOf('.');
  if (dot <= 0 || dot >= fileName.length - 1) return 'bin';

  final ext = fileName.substring(dot + 1).toLowerCase();
  if (!RegExp(r'^[a-z0-9]+$').hasMatch(ext)) return 'bin';
  return ext;
}
