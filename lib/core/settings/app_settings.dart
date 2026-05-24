import 'package:flutter/material.dart';

class AppSettingsState {
  const AppSettingsState({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
    this.loaded = false,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final bool loaded;

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? loaded,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      loaded: loaded ?? this.loaded,
    );
  }
}
