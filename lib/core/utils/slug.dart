String slugify(String input) {
  return input
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'-+'), '-');
}

String uniqueSlug(String base) {
  final timestamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  return '$base-$timestamp';
}
