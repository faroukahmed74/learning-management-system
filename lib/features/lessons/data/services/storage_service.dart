import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/storage_buckets.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../shared/domain/enums/material_type.dart';

class StorageService {
  StorageService({SupabaseClient? client}) : _client = client ?? supabaseClient;

  final SupabaseClient? _client;

  SupabaseClient get _db {
    final client = _client;
    if (client == null) {
      throw const AppException('Supabase is not configured');
    }
    return client;
  }

  Future<String> uploadMaterial({
    required String courseId,
    required String lessonId,
    required String materialId,
    required PlatformFile file,
  }) async {
    final bytes = file.bytes;
    if (bytes == null) {
      throw const AppException('Could not read file bytes');
    }

    final fileName = file.name;
    final path = '$courseId/$lessonId/$materialId/$fileName';

    await _db.storage.from(StorageBuckets.materials).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: file.extension != null
                ? _mimeFromExtension(file.extension!)
                : null,
            upsert: true,
          ),
        );

    return path;
  }

  Future<String> getSignedUrl(String storagePath) async {
    return _db.storage
        .from(StorageBuckets.materials)
        .createSignedUrl(storagePath, 3600);
  }

  Future<String?> getPublicUrl(String bucket, String path) async {
    return _db.storage.from(bucket).getPublicUrl(path);
  }

  MaterialType detectType(PlatformFile file) {
    final ext = (file.extension ?? '').toLowerCase();
    if (['mp4', 'webm', 'mov', 'avi'].contains(ext)) {
      return MaterialType.video;
    }
    if (['mp3', 'm4a', 'wav', 'aac'].contains(ext)) {
      return MaterialType.audio;
    }
    if (['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext)) {
      return MaterialType.image;
    }
    return MaterialType.document;
  }

  String _mimeFromExtension(String ext) {
    return switch (ext.toLowerCase()) {
      'mp4' => 'video/mp4',
      'webm' => 'video/webm',
      'pdf' => 'application/pdf',
      'mp3' => 'audio/mpeg',
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      _ => 'application/octet-stream',
    };
  }

  Future<Uint8List?> downloadMaterial(String storagePath) async {
    return _db.storage.from(StorageBuckets.materials).download(storagePath);
  }
}
