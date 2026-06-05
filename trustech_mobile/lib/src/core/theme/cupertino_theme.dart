import 'package:flutter/cupertino.dart';
import '../constants/app_colors.dart';

class TrustechCupertinoTheme {
  TrustechCupertinoTheme._();

  static const String _fontFamily = 'Geist';
  static const double _barOpacity = 0.9;

  static CupertinoThemeData get lightTheme => CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: TrustechColors.primary,
    primaryContrastingColor: TrustechColors.primaryForeground,
    scaffoldBackgroundColor: TrustechColors.background,
    barBackgroundColor: TrustechColors.card.withValues(alpha: _barOpacity),

    textTheme: const CupertinoTextThemeData(
      primaryColor: TrustechColors.primary,
      textStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 17,
        height: 1.25,
        color: TrustechColors.foreground,
        decoration: TextDecoration.none,
      ),
      navTitleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 17,
        height: 1.15,
        color: TrustechColors.foreground,
        decoration: TextDecoration.none,
      ),
      navLargeTitleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 34,
        height: 1.05,
        color: TrustechColors.foreground,
        decoration: TextDecoration.none,
      ),
      actionTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 17,
        height: 1.25,
        fontWeight: FontWeight.w500,
        color: TrustechColors.primary,
        decoration: TextDecoration.none,
      ),
      pickerTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 21,
        height: 1.15,
        color: TrustechColors.foreground,
        decoration: TextDecoration.none,
      ),
      tabLabelTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 10,
        height: 1.1,
        fontWeight: FontWeight.w600,
        color: TrustechColors.mutedForeground,
        decoration: TextDecoration.none,
      ),
    ),
  );

  static CupertinoThemeData get darkTheme => CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: TrustechColors.primary,
    primaryContrastingColor: TrustechColors.primaryForeground,
    scaffoldBackgroundColor: TrustechColors.darkBackground,
    barBackgroundColor: TrustechColors.darkCard.withValues(alpha: _barOpacity),

    textTheme: const CupertinoTextThemeData(
      primaryColor: TrustechColors.primary,
      textStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 17,
        height: 1.25,
        color: TrustechColors.darkForeground,
        decoration: TextDecoration.none,
      ),
      navTitleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 17,
        height: 1.15,
        color: TrustechColors.darkForeground,
        decoration: TextDecoration.none,
      ),
      navLargeTitleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 34,
        height: 1.05,
        color: TrustechColors.darkForeground,
        decoration: TextDecoration.none,
      ),
      actionTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 17,
        height: 1.25,
        fontWeight: FontWeight.w500,
        color: TrustechColors.primary,
        decoration: TextDecoration.none,
      ),
      pickerTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 21,
        height: 1.15,
        color: TrustechColors.darkForeground,
        decoration: TextDecoration.none,
      ),
      tabLabelTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 10,
        height: 1.1,
        fontWeight: FontWeight.w600,
        color: TrustechColors.darkMutedForeground,
        decoration: TextDecoration.none,
      ),
    ),
  );
}
