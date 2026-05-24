import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final materialSignedUrlProvider =
    FutureProvider.family<String, String>((ref, storagePath) async {
  final service = ref.watch(storageServiceProvider);
  return service.getSignedUrl(storagePath);
});
