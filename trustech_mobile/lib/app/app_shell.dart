import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Localization
import '../l10n/gen/app_localizations.dart';

// Core Features
import '../src/core/platform/platform_info.dart';
import '../src/core/locales/locale_provider.dart';
import '../src/router/app_router.dart';

// Theme
import '../src/core/theme/theme_provider.dart';
import '../src/core/theme/material_theme.dart';
import '../src/core/theme/cupertino_theme.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platformInfo = ref.watch(platformInfoProvider);
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);

    const localizationsDelegates = [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];

    const supportedLocales = AppLocalizations.supportedLocales;

    if (platformInfo.isIOS) {
      final brightness = MediaQuery.platformBrightnessOf(context);
      final isDark =
          themeMode == ThemeMode.dark ||
          (themeMode == ThemeMode.system && brightness == Brightness.dark);

      return CupertinoApp.router(
        title: 'Trustech',
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        locale: locale,
        theme: isDark
            ? TrustechCupertinoTheme.darkTheme
            : TrustechCupertinoTheme.lightTheme,
      );
    }

    return MaterialApp.router(
      title: 'Trustech',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      localizationsDelegates: localizationsDelegates,
      supportedLocales: supportedLocales,
      locale: locale,
      theme: TrustechMaterialTheme.lightTheme,
      darkTheme: TrustechMaterialTheme.darkTheme,
      themeMode: themeMode,
    );
  }
}
