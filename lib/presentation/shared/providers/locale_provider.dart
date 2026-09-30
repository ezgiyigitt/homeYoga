import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_providers.dart';

/// The languages the app ships with. `system` is not a language of its own —
/// it hands the choice back to Flutter, which resolves against the device
/// locale and falls back to English when the device speaks neither.
enum AppLanguage {
  system,
  turkish,
  english,
  french,
  spanish,
  chinese;

  /// The locale to hand to `MaterialApp`. `null` means "let Flutter decide".
  Locale? get locale => switch (this) {
        AppLanguage.system => null,
        AppLanguage.turkish => const Locale('tr'),
        AppLanguage.english => const Locale('en'),
        AppLanguage.french => const Locale('fr'),
        AppLanguage.spanish => const Locale('es'),
        AppLanguage.chinese => const Locale('zh'),
      };

  /// Written in the language itself, so the option is readable no matter
  /// which language the app is currently showing.
  String get nativeName => switch (this) {
        AppLanguage.system => 'System',
        AppLanguage.turkish => 'Türkçe',
        AppLanguage.english => 'English',
        AppLanguage.french => 'Français',
        AppLanguage.spanish => 'Español',
        AppLanguage.chinese => '中文',
      };

  /// Value persisted in SharedPreferences.
  String get storageKey => name;

  static AppLanguage fromStorage(String? value) {
    return AppLanguage.values.firstWhere(
      (l) => l.storageKey == value,
      orElse: () => AppLanguage.system,
    );
  }
}

/// Language preference, stored locally in the same way as the theme mode —
/// it describes this device rather than the account.
///
/// Mirrors [ThemeModeNotifier] deliberately: the view layer only ever reads
/// [localeProvider] / [appLanguageProvider] and calls [setLanguage], so no
/// screen touches SharedPreferences itself.
class LocaleNotifier extends StateNotifier<AppLanguage> {
  final SharedPreferences _prefs;
  static const _key = 'hy_set_language';

  LocaleNotifier(this._prefs)
      : super(AppLanguage.fromStorage(_prefs.getString(_key)));

  void setLanguage(AppLanguage language) {
    if (state == language) return;
    state = language;
    _prefs.setString(_key, language.storageKey);
  }
}

/// The user's raw choice — what the language settings screen ticks.
final appLanguageProvider =
    StateNotifierProvider<LocaleNotifier, AppLanguage>((ref) {
  return LocaleNotifier(ref.watch(sharedPreferencesProvider));
});

/// The locale to hand to `MaterialApp`; `null` follows the device.
final localeProvider = Provider<Locale?>((ref) {
  return ref.watch(appLanguageProvider).locale;
});
