import '../../l10n/app_localizations.dart';

class Validators {
  static String? email(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.emailRequired;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return l10n.emailInvalid;
    }
    return null;
  }

  static String? password(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.passwordRequired;
    }
    if (value.length < 8) {
      return l10n.passwordMinLength;
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return l10n.passwordUppercase;
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return l10n.passwordLowercase;
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return l10n.passwordNumber;
    }
    return null;
  }

  static String? requiredField(String? value, AppLocalizations l10n, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return l10n.fieldRequired(fieldName ?? l10n.required);
    }
    return null;
  }
}
