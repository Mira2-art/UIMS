import 'package:flutter/material.dart';

import '../../../core/constants/app_typography.dart';

/// Visual variants for [TrustechButton].
enum TrustechButtonVariant { primary, secondary, outline, text, destructive }

/// The single button component for the app. Wraps Material buttons so every
/// call site shares the same sizing, radius, loading and icon behaviour while
/// still inheriting colours from the active [ThemeData].
class TrustechButton extends StatelessWidget {
  const TrustechButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = TrustechButtonVariant.primary,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.expand = true,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final TrustechButtonVariant variant;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;

  /// Stretch to the full available width (default) or hug content.
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final disabled = isLoading || onPressed == null;

    final child = _content(context);

    Widget button;
    switch (variant) {
      case TrustechButtonVariant.primary:
        button = FilledButton(onPressed: disabled ? null : onPressed, child: child);
        break;
      case TrustechButtonVariant.secondary:
        button = FilledButton(
          onPressed: disabled ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: cs.secondary,
            foregroundColor: cs.onSecondary,
          ),
          child: child,
        );
        break;
      case TrustechButtonVariant.destructive:
        button = FilledButton(
          onPressed: disabled ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: cs.error,
            foregroundColor: cs.onError,
          ),
          child: child,
        );
        break;
      case TrustechButtonVariant.outline:
        button = OutlinedButton(onPressed: disabled ? null : onPressed, child: child);
        break;
      case TrustechButtonVariant.text:
        button = TextButton(onPressed: disabled ? null : onPressed, child: child);
        break;
    }

    return SizedBox(
      width: expand ? double.infinity : null,
      height: height,
      child: button,
    );
  }

  Widget _content(BuildContext context) {
    if (isLoading) {
      final cs = Theme.of(context).colorScheme;
      final color = switch (variant) {
        TrustechButtonVariant.outline ||
        TrustechButtonVariant.text => cs.primary,
        TrustechButtonVariant.secondary => cs.onSecondary,
        TrustechButtonVariant.destructive => cs.onError,
        _ => cs.onPrimary,
      };
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2.2, color: color),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TrustechTypography.button,
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, size: 18),
        ],
      ],
    );
  }
}
