import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_provider.dart';

/// Resolves brand colours against the active brightness (light/dark).
///
/// Two access styles are supported:
///  * Riverpod-aware (`ref` provided) — respects the user's saved [themeProvider]
///    preference, including `ThemeMode.system`.
///  * Context-only (`ref == null`) — falls back to the platform brightness.
///
/// For most widget code prefer the [ThemeContextX] extension below.
class ThemeHelper {
  ThemeHelper._();

  static bool isDarkMode(BuildContext context, [WidgetRef? ref]) {
    final systemBrightness = MediaQuery.platformBrightnessOf(context);
    if (ref != null) {
      final mode = ref.watch(themeProvider);
      return mode == ThemeMode.dark ||
          (mode == ThemeMode.system && systemBrightness == Brightness.dark);
    }
    return systemBrightness == Brightness.dark;
  }

  static Color background(BuildContext context, [WidgetRef? ref]) =>
      isDarkMode(context, ref)
          ? TrustechColors.darkBackground
          : TrustechColors.background;

  static Color foreground(BuildContext context, [WidgetRef? ref]) =>
      isDarkMode(context, ref)
          ? TrustechColors.darkForeground
          : TrustechColors.foreground;

  static Color card(BuildContext context, [WidgetRef? ref]) =>
      isDarkMode(context, ref) ? TrustechColors.darkCard : TrustechColors.card;

  static Color muted(BuildContext context, [WidgetRef? ref]) =>
      isDarkMode(context, ref)
          ? TrustechColors.darkMuted
          : TrustechColors.muted;

  static Color mutedForeground(BuildContext context, [WidgetRef? ref]) =>
      isDarkMode(context, ref)
          ? TrustechColors.darkMutedForeground
          : TrustechColors.mutedForeground;

  static Color border(BuildContext context, [WidgetRef? ref]) =>
      isDarkMode(context, ref)
          ? TrustechColors.darkBorder
          : TrustechColors.border;

  static Color input(BuildContext context, [WidgetRef? ref]) =>
      isDarkMode(context, ref) ? TrustechColors.darkInput : TrustechColors.input;
}

/// Ergonomic, context-only theme accessors. These read the platform brightness
/// (sufficient for `ThemeMode.system`); when a widget already exposes a [WidgetRef]
/// and must honour an explicit light/dark override, use [ThemeHelper] directly.
extension ThemeContextX on BuildContext {
  bool get isDark => ThemeHelper.isDarkMode(this);

  Color get cBackground => ThemeHelper.background(this);
  Color get cForeground => ThemeHelper.foreground(this);
  Color get cCard => ThemeHelper.card(this);
  Color get cMuted => ThemeHelper.muted(this);
  Color get cMutedForeground => ThemeHelper.mutedForeground(this);
  Color get cBorder => ThemeHelper.border(this);
  Color get cInput => ThemeHelper.input(this);
}
