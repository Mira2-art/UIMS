import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';

class AppLocales {
  static const en = Locale('en');
  static const fr = Locale('fr');
  static const supported = <Locale>[en, fr];
  static const fallback = en;
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale?> {
  static const _prefsKey = 'selected_locale';

  @override
  Locale? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final code = prefs.getString(_prefsKey);

    if (code == 'en') return AppLocales.en;
    if (code == 'fr') return AppLocales.fr;

    return null;
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;

    final prefs = ref.read(sharedPreferencesProvider);

    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }
}
