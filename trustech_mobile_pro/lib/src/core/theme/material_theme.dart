import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class TrustechMaterialTheme {
  TrustechMaterialTheme._();

  static const String _fontFamily = 'Geist';
  static const double _radius = 8;

  static ThemeData get lightTheme {
    final scheme = TrustechColorScheme.lightScheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: TrustechColors.background,

      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: TrustechColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: TrustechColors.foreground),
        actionsIconTheme: IconThemeData(color: TrustechColors.foreground),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          color: TrustechColors.foreground,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: TrustechColors.primary,
        selectionColor: TrustechColors.primary.withValues(alpha: 0.25),
        selectionHandleColor: TrustechColors.primary,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TrustechColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: _border(TrustechColors.input),
        enabledBorder: _border(TrustechColors.input),
        focusedBorder: _border(TrustechColors.primary, width: 2),
        errorBorder: _border(TrustechColors.destructive),
        focusedErrorBorder: _border(TrustechColors.destructive, width: 2),
        hintStyle: const TextStyle(
          fontFamily: _fontFamily,
          color: TrustechColors.mutedForeground,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          fontFamily: _fontFamily,
          color: TrustechColors.mutedForeground,
          fontWeight: FontWeight.w500,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TrustechColors.primary,
          foregroundColor: TrustechColors.primaryForeground,
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
          backgroundColor: TrustechColors.primary,
          foregroundColor: TrustechColors.primaryForeground,
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
          foregroundColor: TrustechColors.primary,
          side: const BorderSide(color: TrustechColors.border),
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
          foregroundColor: TrustechColors.primary,
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
        backgroundColor: TrustechColors.muted,
        selectedColor: TrustechColors.primary.withValues(alpha: 0.15),
        disabledColor: TrustechColors.muted,
        labelStyle: const TextStyle(
          fontFamily: _fontFamily,
          color: TrustechColors.foreground,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: _fontFamily,
          color: TrustechColors.foreground,
          fontWeight: FontWeight.w500,
        ),
        side: const BorderSide(color: TrustechColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: TrustechColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(_radius * 2),
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: TrustechColors.foreground,
        contentTextStyle: const TextStyle(
          fontFamily: _fontFamily,
          color: TrustechColors.background,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: scheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      dividerTheme: const DividerThemeData(
        color: TrustechColors.border,
        thickness: 1,
        space: 1,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TrustechColors.primaryForeground;
          }
          return TrustechColors.card;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TrustechColors.primary;
          }
          return TrustechColors.border;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TrustechColors.primary;
          }
          return Colors.transparent;
        }),
        side: const BorderSide(color: TrustechColors.border, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TrustechColors.primary;
          }
          return TrustechColors.border;
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    final scheme = TrustechColorScheme.darkScheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: TrustechColors.darkBackground,

      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: TrustechColors.darkBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: TrustechColors.darkForeground),
        actionsIconTheme: IconThemeData(color: TrustechColors.darkForeground),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          color: TrustechColors.darkForeground,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: TrustechColors.primary,
        selectionColor: TrustechColors.primary.withValues(alpha: 0.30),
        selectionHandleColor: TrustechColors.primary,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TrustechColors.darkInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: _border(TrustechColors.darkBorder),
        enabledBorder: _border(TrustechColors.darkBorder),
        focusedBorder: _border(TrustechColors.primary, width: 2),
        errorBorder: _border(TrustechColors.destructive),
        focusedErrorBorder: _border(TrustechColors.destructive, width: 2),
        hintStyle: const TextStyle(
          fontFamily: _fontFamily,
          color: TrustechColors.darkMutedForeground,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          fontFamily: _fontFamily,
          color: TrustechColors.darkMutedForeground,
          fontWeight: FontWeight.w500,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TrustechColors.primary,
          foregroundColor: TrustechColors.primaryForeground,
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
          backgroundColor: TrustechColors.primary,
          foregroundColor: TrustechColors.primaryForeground,
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
          foregroundColor: TrustechColors.primary,
          side: const BorderSide(color: TrustechColors.darkBorder),
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
          foregroundColor: TrustechColors.primary,
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
        backgroundColor: TrustechColors.darkMuted,
        selectedColor: TrustechColors.primary.withValues(alpha: 0.20),
        disabledColor: TrustechColors.darkMuted,
        labelStyle: const TextStyle(
          fontFamily: _fontFamily,
          color: TrustechColors.darkForeground,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: _fontFamily,
          color: TrustechColors.darkForeground,
          fontWeight: FontWeight.w500,
        ),
        side: const BorderSide(color: TrustechColors.darkBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: TrustechColors.darkCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(_radius * 2),
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: TrustechColors.darkCard,
        contentTextStyle: const TextStyle(
          fontFamily: _fontFamily,
          color: TrustechColors.darkForeground,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: scheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      dividerTheme: const DividerThemeData(
        color: TrustechColors.darkBorder,
        thickness: 1,
        space: 1,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TrustechColors.primaryForeground;
          }
          return TrustechColors.darkCard;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TrustechColors.primary;
          }
          return TrustechColors.darkBorder;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TrustechColors.primary;
          }
          return Colors.transparent;
        }),
        side: const BorderSide(color: TrustechColors.darkBorder, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TrustechColors.primary;
          }
          return TrustechColors.darkBorder;
        }),
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
