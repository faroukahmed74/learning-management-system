import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/storage_buckets.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/supabase_client.dart';

class ProfileRepository {
  ProfileRepository({SupabaseClient? client}) : _client = client ?? supabaseClient;

  final SupabaseClient? _client;

  SupabaseClient get _db {
    final client = _client;
    if (client == null) throw const AppException('Supabase is not configured');
    return client;
  }

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? bio,
    String? nativeLanguage,
    String? targetLanguage,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;
    if (bio != null) updates['bio'] = bio;
    if (nativeLanguage != null) updates['native_language'] = nativeLanguage;
    if (targetLanguage != null) updates['target_language'] = targetLanguage;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    final row = await _db
        .from('profiles')
        .update(updates)
        .eq('id', userId)
        .select()
        .single();
    return Map<String, dynamic>.from(row);
  }

  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final ext = fileName.contains('.') ? fileName.split('.').last : 'jpg';
    final path = '$userId/avatar.$ext';

    await _db.storage.from(StorageBuckets.avatars).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
        );

    return _db.storage.from(StorageBuckets.avatars).getPublicUrl(path);
  }
}
