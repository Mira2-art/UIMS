import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Severity of a snackbar message, mapped to a brand colour accent.
enum SnackKind { info, success, warning, error }

/// Helper for showing consistent, themed snackbars from anywhere with a
/// [BuildContext]. Usage: `AppSnackbar.success(context, 'Saved');`
class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context,
    String message, {
    SnackKind kind = SnackKind.info,
  }) {
    final (icon, accent) = switch (kind) {
      SnackKind.success => (Icons.check_circle_outline, TrustechColors.success),
      SnackKind.warning => (Icons.warning_amber_rounded, TrustechColors.warning),
      SnackKind.error => (Icons.error_outline, TrustechColors.error),
      SnackKind.info => (Icons.info_outline, TrustechColors.primary),
    };

    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: accent, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void info(BuildContext c, String m) => show(c, m, kind: SnackKind.info);
  static void success(BuildContext c, String m) =>
      show(c, m, kind: SnackKind.success);
  static void warning(BuildContext c, String m) =>
      show(c, m, kind: SnackKind.warning);
  static void error(BuildContext c, String m) =>
      show(c, m, kind: SnackKind.error);
}
