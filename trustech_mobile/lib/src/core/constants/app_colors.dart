import 'package:flutter/material.dart';

class TrustechColors {
  TrustechColors._();

  /// Primary brand color - Teal
  static const Color primary = Color(0xFF3D7A8C);
  static const Color primaryForeground = Color(0xFFFBFBFB);

  /// Secondary brand color - Amber/Orange
  static const Color secondary = Color(0xFFE8A847);
  static const Color secondaryForeground = Color(0xFFF7F7F7);

  /// Destructive/Error - Red
  static const Color destructive = Color(0xFFDC3545);
  static const Color destructiveForeground = Color(0xFFFFFFFF);

  /// Background - Near white
  static const Color background = Color(0xFFFAFAFA);

  /// Foreground/Text - Near black
  static const Color foreground = Color(0xFF252525);

  /// Card background - Pure white
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF252525);

  /// Muted background
  static const Color muted = Color(0xFFF7F7F7);

  /// Muted foreground/Secondary text
  static const Color mutedForeground = Color(0xFF8E8E8E);

  /// Accent background
  static const Color accent = Color(0xFFF7F7F7);
  static const Color accentForeground = Color(0xFF343434);

  /// Border color
  static const Color border = Color(0xFFEBEBEB);

  /// Input border
  static const Color input = Color(0xFFEBEBEB);

  /// Focus ring
  static const Color ring = Color(0xFFB5B5B5);

  // CHART COLORS
  static const Color chart1 = Color(0xFF9BB8ED);
  static const Color chart2 = Color(0xFF6B7FD4);
  static const Color chart3 = Color(0xFF5A6BC7);
  static const Color chart4 = Color(0xFF4A5AB8);
  static const Color chart5 = Color(0xFF3A4A9A);

  /// Success - Green
  static const Color success = Color(0xFF34C759);
  static const Color warning = secondary;
  static const Color error = destructive;
  static const Color info = primary;

  // STOCK STATUS COLORS
  static const Color stockHealthy = Color(0xFF34C759);
  static const Color stockLow = secondary;
  static const Color stockCritical = destructive;
  static const Color stockOut = mutedForeground;

  // TEXT COLORS
  static const Color textPrimary = foreground;
  static const Color textSecondary = mutedForeground;
  static const Color textTertiary = Color(0xFFC7C7CC);
  static const Color textOnPrimary = primaryForeground;

  // DARK MODE COLORS
  static const Color darkBackground = Color(0xFF252525);
  static const Color darkForeground = Color(0xFFFBFBFB);
  static const Color darkCard = Color(0xFF343434);
  static const Color darkCardForeground = Color(0xFFFBFBFB);
  static const Color darkMuted = Color(0xFF454545);
  static const Color darkMutedForeground = Color(0xFFB5B5B5);
  static const Color darkBorder = Color(0xFF474747);
  static const Color darkInput = Color(0xFF404040);
}

extension TrustechColorScheme on BuildContext {
  static ColorScheme get lightScheme => const ColorScheme.light(
    primary: TrustechColors.primary,
    onPrimary: TrustechColors.primaryForeground,
    secondary: TrustechColors.secondary,
    onSecondary: TrustechColors.secondaryForeground,
    error: TrustechColors.destructive,
    onError: TrustechColors.destructiveForeground,
    surface: TrustechColors.card,
    onSurface: TrustechColors.cardForeground,
    outline: TrustechColors.border,
  );

  static ColorScheme get darkScheme => const ColorScheme.dark(
    primary: TrustechColors.primary,
    onPrimary: TrustechColors.primaryForeground,
    secondary: TrustechColors.secondary,
    onSecondary: TrustechColors.secondaryForeground,
    error: TrustechColors.destructive,
    onError: TrustechColors.destructiveForeground,
    surface: TrustechColors.darkCard,
    onSurface: TrustechColors.darkCardForeground,
    outline: TrustechColors.darkBorder,
  );
}
