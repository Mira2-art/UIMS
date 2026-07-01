import 'package:flutter/material.dart';

import '../../../core/constants/app_typography.dart';

/// A single-select option row (label + optional leading icon + trailing check
/// when selected). Stack several inside a sheet/list for theme/language pickers.
class SegmentedSelectorRow extends StatelessWidget {
  const SegmentedSelectorRow({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leadingIcon,
    this.trailingText,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? leadingIcon;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 20, color: selected ? cs.primary : cs.onSurfaceVariant),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Text(
                label,
                style: TrustechTypography.bodyLarge.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? cs.primary : cs.onSurface,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(trailingText!, style: TrustechTypography.bodySmall.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(width: 8),
            ],
            if (selected) Icon(Icons.check_circle, color: cs.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
