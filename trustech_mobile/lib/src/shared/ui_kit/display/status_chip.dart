import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

/// Semantic kinds for [StatusChip], each mapped to a brand accent.
enum StatusKind { success, warning, error, info, neutral }

/// A small pill badge with a leading dot, used for statuses across the app
/// (paid / pending / active / overdue, etc).
///
/// Extend by passing a custom [label]; for one-off colors use [StatusChip.custom].
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, this.kind = StatusKind.neutral})
      : _accent = null;

  /// Escape hatch for a bespoke accent that isn't one of the semantic kinds.
  const StatusChip.custom({super.key, required this.label, required Color accent})
      : kind = StatusKind.neutral,
        _accent = accent;

  final String label;
  final StatusKind kind;
  final Color? _accent;

  Color get _color {
    if (_accent != null) return _accent;
    switch (kind) {
      case StatusKind.success:
        return TrustechColors.success;
      case StatusKind.warning:
        return TrustechColors.secondary;
      case StatusKind.error:
        return TrustechColors.destructive;
      case StatusKind.info:
        return TrustechColors.primary;
      case StatusKind.neutral:
        return TrustechColors.mutedForeground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TrustechTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
