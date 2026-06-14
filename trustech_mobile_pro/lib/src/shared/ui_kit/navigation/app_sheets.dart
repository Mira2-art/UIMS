import 'package:flutter/material.dart';

/// Helper to display standard modal bottom sheets.
/// Ensures consistent theming, scrim, and scrolling behavior.
Future<T?> showAppSheet<T>(
  BuildContext context,
  WidgetBuilder builder, {
  bool isScrollControlled = true,
  bool useSafeArea = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    backgroundColor: Colors.transparent, // SheetScaffold paints its own surface
    barrierColor: Colors.black.withValues(alpha: 0.5), // ~50% dark scrim
    builder: (context) => builder(context),
  );
}
