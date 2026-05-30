import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/env.dart';
import '../../../../core/network/supabase_client.dart';
import '../../domain/entities/app_user.dart';
import '../../../../shared/domain/enums/user_role.dart';

export '../../domain/entities/app_user.dart';
export '../../../../core/router/route_guards.dart' show homeRouteForRole;

final authStateProvider = StreamProvider<AuthState?>((ref) {
  if (!Env.isConfigured) {
    return Stream.value(null);
  }
  return Supabase.instance.client.auth.onAuthStateChange.map((data) => data);
});

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  if (!Env.isConfigured) return null;

  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) return null;

  final response = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('id', session.user.id)
      .maybeSingle();

  if (response == null) return null;
  return AppUser.fromJson(Map<String, dynamic>.from(response));
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController() : super(const AsyncData(null));

  SupabaseClient? get _client => supabaseClient;

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      if (_client == null) {
        throw Exception('Supabase is not configured. Update your .env file.');
      }
      await _client!.auth.signInWithPassword(email: email, password: password);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? nativeLanguage,
    String? targetLanguage,
  }) async {
    state = const AsyncLoading();
    try {
      if (_client == null) {
        throw Exception('Supabase is not configured. Update your .env file.');
      }
      await _client!.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': UserRole.student.name,
          if (nativeLanguage != null) 'native_language': nativeLanguage,
          if (targetLanguage != null) 'target_language': targetLanguage,
        },
      );
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (_client == null) return;
    await _client!.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    if (_client == null) {
      throw Exception('Supabase is not configured. Update your .env file.');
    }
    await _client!.auth.resetPasswordForEmail(email);
  }

  Future<void> resendVerificationEmail(String email) async {
    if (_client == null) {
      throw Exception('Supabase is not configured. Update your .env file.');
    }
    await _client!.auth.resend(
      type: OtpType.signup,
      email: email.trim(),
    );
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController();
});
