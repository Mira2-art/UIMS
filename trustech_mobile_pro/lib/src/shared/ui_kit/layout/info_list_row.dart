import 'package:flutter/material.dart';

import '../../../core/constants/app_typography.dart';
import '../../utils/theme_helper.dart';

/// The workhorse list row: optional leading icon chip, title + subtitle, and a
/// trailing slot (value text, chip, chevron, or any widget).
///
/// Compose many rows inside an [InfoListCard] to get the bordered, divided
/// "data display" card from the design. Extend per use via the trailing slots.
class InfoListRow extends StatelessWidget {
  const InfoListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.iconAccent,
    this.trailingText,
    this.trailing,
    this.showChevron = false,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final String title;
  final String? subtitle;

  /// Quick leading icon (wrapped in an accent chip). Ignored if [leading] is set.
  final IconData? icon;
  final Widget? leading;
  final Color? iconAccent;

  /// Trailing value text (e.g. an amount). Ignored if [trailing] is set.
  final String? trailingText;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = iconAccent ?? cs.primary;

    Widget? lead = leading;
    if (lead == null && icon != null) {
      lead = Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: accent),
      );
    }

    Widget? trail = trailing;
    if (trail == null && trailingText != null) {
      trail = Text(
        trailingText!,
        style: TrustechTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700, color: cs.primary),
      );
    }
    if (trail == null && showChevron) {
      trail = Icon(Icons.chevron_right, color: cs.onSurfaceVariant);
    }

    final row = Padding(
      padding: padding,
      child: Row(
        children: [
          if (lead != null) ...[lead, const SizedBox(width: 14)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TrustechTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trail != null) ...[const SizedBox(width: 12), trail],
        ],
      ),
    );

    if (onTap == null) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

/// Bordered, rounded container that stacks [InfoListRow]s with hairline dividers.
class InfoListCard extends StatelessWidget {
  const InfoListCard({super.key, required this.children, this.margin = EdgeInsets.zero});

  final List<Widget> children;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final divided = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      divided.add(children[i]);
      if (i != children.length - 1) {
        divided.add(Divider(height: 1, thickness: 1, color: context.cBorder));
      }
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: context.cCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: divided),
    );
  }
}
