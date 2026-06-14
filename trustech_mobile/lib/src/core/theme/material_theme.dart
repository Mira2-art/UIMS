import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class TrustechMaterialTheme {
  TrustechMaterialTheme._();

  static const String _fontFamily = 'Geist';
  static const double _radius = 8;

  static ThemeData get lightTheme {
    // Fully specify ColorScheme for Material 3 design system, mapping to brand tokens
    final lightScheme = ColorScheme.light(
      primary: TrustechColors.primary,
      onPrimary: TrustechColors.primaryForeground,
      primaryContainer: TrustechColors.primary,
      onPrimaryContainer: TrustechColors.primaryForeground,
      secondary: TrustechColors.secondary,
      onSecondary: TrustechColors.secondaryForeground,
      secondaryContainer: TrustechColors.secondary,
      onSecondaryContainer: TrustechColors.secondaryForeground,
      tertiary: TrustechColors.textTertiary,
      onTertiary: TrustechColors.textPrimary,
      tertiaryContainer: TrustechColors.accent,
      onTertiaryContainer: TrustechColors.accentForeground,
      error: TrustechColors.destructive,
      onError: TrustechColors.destructiveForeground,
      errorContainer: TrustechColors.destructive,
      onErrorContainer: TrustechColors.destructiveForeground,
      surface: TrustechColors.card,
      onSurface: TrustechColors.cardForeground,
      onSurfaceVariant: TrustechColors.mutedForeground,
      outline: TrustechColors.border,
      outlineVariant: TrustechColors.input,
      shadow: Colors.black.withValues(alpha: 0.1),
      scrim: Colors.black.withValues(alpha: 0.4),
      inverseSurface: TrustechColors.darkBackground,
      onInverseSurface: TrustechColors.darkForeground,
      inversePrimary: TrustechColors.darkBackground,
      surfaceTint: Colors.transparent, // Neutralize global elevation tint

      // Map M3 surface-container roles to our brand ladder
      surfaceDim: TrustechColors.background, // Same as background
      surfaceBright: TrustechColors.card, // Same as card
      surfaceContainerLowest: TrustechColors.surfaceContainerLowest,
      surfaceContainerLow: TrustechColors.surfaceContainerLow,
      surfaceContainer: TrustechColors.surfaceContainer,
      surfaceContainerHigh: TrustechColors.surfaceContainerHigh,
      surfaceContainerHighest: TrustechColors.surfaceContainerHighest,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
      colorScheme: lightScheme,
      scaffoldBackgroundColor: TrustechColors.background,

      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: lightScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: lightScheme.onSurface),
        actionsIconTheme: IconThemeData(color: lightScheme.onSurface),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          color: lightScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: lightScheme.primary,
        selectionColor: lightScheme.primary.withValues(alpha: 0.25),
        selectionHandleColor: lightScheme.primary,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightScheme.surfaceContainerHigh, // Use surfaceContainerHigh for input fill
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: _border(lightScheme.outlineVariant),
        enabledBorder: _border(lightScheme.outlineVariant),
        focusedBorder: _border(lightScheme.primary, width: 2),
        errorBorder: _border(lightScheme.error),
        focusedErrorBorder: _border(lightScheme.error, width: 2),
        hintStyle: TextStyle(
          fontFamily: _fontFamily,
          color: lightScheme.onSurfaceVariant,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
          color: lightScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightScheme.primary,
          foregroundColor: lightScheme.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: lightScheme.primary,
          foregroundColor: lightScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightScheme.primary,
          side: BorderSide(color: lightScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: lightScheme.surfaceContainerHigh,
        selectedColor: lightScheme.primary.withValues(alpha: 0.15),
        disabledColor: lightScheme.surfaceContainerHigh,
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
          color: lightScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: _fontFamily,
          color: lightScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(color: lightScheme.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: lightScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(_radius * 2),
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightScheme.onSurface,
        contentTextStyle: TextStyle(
          fontFamily: _fontFamily,
          color: lightScheme.surface,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: lightScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      dividerTheme: DividerThemeData(
        color: lightScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return lightScheme.onPrimary;
          }
          return lightScheme.surfaceContainerLow;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return lightScheme.primary;
          }
          return lightScheme.outlineVariant;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return lightScheme.primary;
          }
          return Colors.transparent;
        }),
        side: BorderSide(color: lightScheme.outlineVariant, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return lightScheme.primary;
          }
          return lightScheme.outlineVariant;
        }),
      ),

      cardTheme: CardThemeData(
        color: lightScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide(color: lightScheme.outline, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius * 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    // Fully specify ColorScheme for Material 3 design system, mapping to brand tokens
    final darkScheme = ColorScheme.dark(
      primary: TrustechColors.primary,
      onPrimary: TrustechColors.primaryForeground,
      primaryContainer: TrustechColors.primary,
      onPrimaryContainer: TrustechColors.primaryForeground,
      secondary: TrustechColors.secondary,
      onSecondary: TrustechColors.secondaryForeground,
      secondaryContainer: TrustechColors.secondary,
      onSecondaryContainer: TrustechColors.secondaryForeground,
      tertiary: TrustechColors.textTertiary,
      onTertiary: TrustechColors.textPrimary,
      tertiaryContainer: TrustechColors.darkMuted,
      onTertiaryContainer: TrustechColors.darkForeground,
      error: TrustechColors.destructive,
      onError: TrustechColors.destructiveForeground,
      errorContainer: TrustechColors.destructive,
      onErrorContainer: TrustechColors.destructiveForeground,
      surface: TrustechColors.darkCard,
      onSurface: TrustechColors.darkCardForeground,
      onSurfaceVariant: TrustechColors.darkMutedForeground,
      outline: TrustechColors.darkBorder,
      outlineVariant: TrustechColors.darkInput,
      shadow: Colors.black.withValues(alpha: 0.2),
      scrim: Colors.black.withValues(alpha: 0.6),
      inverseSurface: TrustechColors.background,
      onInverseSurface: TrustechColors.foreground,
      inversePrimary: TrustechColors.background,
      surfaceTint: Colors.transparent, // Neutralize global elevation tint

      // Map M3 surface-container roles to our brand ladder
      surfaceDim: TrustechColors.darkBackground, // Same as background
      surfaceBright: TrustechColors.darkCard, // Same as card
      surfaceContainerLowest: TrustechColors.darkSurfaceContainerLowest,
      surfaceContainerLow: TrustechColors.darkSurfaceContainerLow,
      surfaceContainer: TrustechColors.darkSurfaceContainer,
      surfaceContainerHigh: TrustechColors.darkSurfaceContainerHigh,
      surfaceContainerHighest: TrustechColors.darkSurfaceContainerHighest,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
      colorScheme: darkScheme,
      scaffoldBackgroundColor: TrustechColors.darkBackground,

      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: darkScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: darkScheme.onSurface),
        actionsIconTheme: IconThemeData(color: darkScheme.onSurface),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          color: darkScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: darkScheme.primary,
        selectionColor: darkScheme.primary.withValues(alpha: 0.30),
        selectionHandleColor: darkScheme.primary,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkScheme.surfaceContainerHigh, // Use surfaceContainerHigh for input fill
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: _border(darkScheme.outlineVariant),
        enabledBorder: _border(darkScheme.outlineVariant),
        focusedBorder: _border(darkScheme.primary, width: 2),
        errorBorder: _border(darkScheme.error),
        focusedErrorBorder: _border(darkScheme.error, width: 2),
        hintStyle: TextStyle(
          fontFamily: _fontFamily,
          color: darkScheme.onSurfaceVariant,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
          color: darkScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkScheme.primary,
          foregroundColor: darkScheme.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: darkScheme.primary,
          foregroundColor: darkScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkScheme.primary,
          side: BorderSide(color: darkScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: darkScheme.surfaceContainerHigh,
        selectedColor: darkScheme.primary.withValues(alpha: 0.20),
        disabledColor: darkScheme.surfaceContainerHigh,
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
          color: darkScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: _fontFamily,
          color: darkScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(color: darkScheme.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(_radius * 2),
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkScheme.onSurface,
        contentTextStyle: TextStyle(
          fontFamily: _fontFamily,
          color: darkScheme.surface,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: darkScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      dividerTheme: DividerThemeData(
        color: darkScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkScheme.onPrimary;
          }
          return darkScheme.surfaceContainerLow;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkScheme.primary;
          }
          return darkScheme.outlineVariant;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkScheme.primary;
          }
          return Colors.transparent;
        }),
        side: BorderSide(color: darkScheme.outlineVariant, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkScheme.primary;
          }
          return darkScheme.outlineVariant;
        }),
      ),

      cardTheme: CardThemeData(
        color: darkScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide(color: darkScheme.outline, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius * 2),
        ),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
