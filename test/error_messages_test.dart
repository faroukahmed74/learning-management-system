import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:learning_management_system/core/utils/error_messages.dart';
import 'package:learning_management_system/l10n/app_localizations.dart';

void main() {
  final l10n = AppLocalizations(const Locale('en'));

  test('maps email not confirmed auth error', () {
    final error = AuthApiException(
      'Email not confirmed',
      statusCode: '400',
      code: 'email_not_confirmed',
    );

    expect(
      userFriendlyErrorMessage(error, l10n),
      l10n.emailNotConfirmed,
    );
  });

  test('maps invalid credentials from exception text', () {
    expect(
      userFriendlyErrorMessage(
        Exception('AuthApiException(message: Invalid login credentials)'),
        l10n,
      ),
      l10n.invalidCredentials,
    );
  });

  test('falls back to generic error for unknown errors', () {
    expect(
      userFriendlyErrorMessage(Exception('Unexpected failure'), l10n),
      l10n.genericError,
    );
  });
}
