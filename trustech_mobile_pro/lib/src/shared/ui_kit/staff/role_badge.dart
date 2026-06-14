import 'package:flutter/material.dart';

import '../../../core/constants/app_typography.dart';

/// Small role pill (LECTURER / REGISTRAR / FINANCE / HR / ADMIN / STAFF).
class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.label, this.accent});

  final String label;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final a = accent ?? cs.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: a.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: TrustechTypography.overline.copyWith(color: a),
      ),
    );
  }
}

/// Label-over-value field for rendering "tables" as stacked rows on mobile
/// (never horizontal-scroll — spec §4).
class StackedField extends StatelessWidget {
  const StackedField({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: TrustechTypography.overline.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TrustechTypography.bodyMedium.copyWith(color: cs.onSurface),
        ),
      ],
    );
  }
}
