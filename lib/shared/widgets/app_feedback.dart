import 'package:flutter/material.dart';

import '../../core/utils/error_messages.dart';
import '../../l10n/app_localizations.dart';

void showErrorSnackBar(BuildContext context, Object error) {
  final message = context.l10n.friendlyError(error);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
