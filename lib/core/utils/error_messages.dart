import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../errors/app_exception.dart';

/// Converts thrown errors into short, user-facing messages.
String userFriendlyErrorMessage(Object error, AppLocalizations l10n) {
  if (error is AppException) {
    return _mapCode(error.code, l10n) ?? error.message;
  }

  if (error is AuthException) {
    return _mapAuth(error, l10n);
  }

  if (error is PostgrestException) {
    return _mapPostgrest(error, l10n);
  }

  if (error is StorageException) {
    return _mapStorage(error, l10n);
  }

  return _mapFromText(error.toString(), l10n) ?? l10n.genericError;
}

String? _mapCode(String? code, AppLocalizations l10n) {
  if (code == null) return null;
  return switch (code) {
    'email_not_confirmed' => l10n.emailNotConfirmed,
    'invalid_credentials' => l10n.invalidCredentials,
    'user_not_found' => l10n.invalidCredentials,
    'email_exists' || 'user_already_exists' => l10n.emailAlreadyExists,
    'weak_password' => l10n.passwordMinLength,
    'over_request_rate_limit' || 'too_many_requests' => l10n.tooManyRequests,
    'permission_denied' => l10n.permissionDenied,
    'unique_violation' => l10n.alreadyExists,
    'invalid_key' => l10n.uploadInvalidFile,
    _ => null,
  };
}

String _mapAuth(AuthException error, AppLocalizations l10n) {
  return _mapCode(error.code, l10n) ??
      _mapFromText(error.message, l10n) ??
      _mapFromText(error.toString(), l10n) ??
      l10n.genericError;
}

String _mapPostgrest(PostgrestException error, AppLocalizations l10n) {
  final code = error.code;
  if (code == '23505') return l10n.alreadyExists;
  if (code == '42501' || code == 'PGRST301') return l10n.permissionDenied;

  return _mapFromText(error.message, l10n) ??
      _mapFromText(error.toString(), l10n) ??
      l10n.loadFailed;
}

String _mapStorage(StorageException error, AppLocalizations l10n) {
  if (error.error == 'InvalidKey' || error.message.contains('Invalid key')) {
    return l10n.uploadInvalidFile;
  }
  if (error.statusCode == '401' || error.statusCode == '403') {
    return l10n.permissionDenied;
  }

  return _mapFromText(error.message, l10n) ??
      _mapFromText(error.toString(), l10n) ??
      l10n.uploadFailed;
}

String? _mapFromText(String text, AppLocalizations l10n) {
  final lower = text.toLowerCase();

  if (lower.contains('email not confirmed') ||
      lower.contains('email_not_confirmed')) {
    return l10n.emailNotConfirmed;
  }
  if (lower.contains('invalid login credentials') ||
      lower.contains('invalid_credentials') ||
      lower.contains('invalid email or password')) {
    return l10n.invalidCredentials;
  }
  if (lower.contains('user already registered') ||
      lower.contains('email_exists') ||
      lower.contains('already been registered')) {
    return l10n.emailAlreadyExists;
  }
  if (lower.contains('rate limit') ||
      lower.contains('too many requests') ||
      lower.contains('over_request_rate_limit')) {
    return l10n.tooManyRequests;
  }
  if (lower.contains('jwt expired') ||
      lower.contains('session_not_found') ||
      lower.contains('refresh_token_not_found')) {
    return l10n.sessionExpired;
  }
  if (lower.contains('row-level security') ||
      lower.contains('permission denied') ||
      lower.contains('not authorized') ||
      lower.contains('42501')) {
    return l10n.permissionDenied;
  }
  if (lower.contains('duplicate key') ||
      lower.contains('unique constraint') ||
      lower.contains('23505')) {
    return l10n.alreadyExists;
  }
  if (lower.contains('invalid key') || lower.contains('invalidkey')) {
    return l10n.uploadInvalidFile;
  }
  if (lower.contains('supabase is not configured') ||
      lower.contains('supabase not configured')) {
    return l10n.supabaseNotConfigured;
  }
  if (lower.contains('socketexception') ||
      lower.contains('failed host lookup') ||
      lower.contains('network is unreachable') ||
      lower.contains('connection refused') ||
      lower.contains('connection timed out')) {
    return l10n.networkError;
  }
  if (lower.contains('not signed in')) {
    return l10n.notSignedIn;
  }

  return null;
}

extension AppLocalizationsError on AppLocalizations {
  String friendlyError(Object error) => userFriendlyErrorMessage(error, this);
}
