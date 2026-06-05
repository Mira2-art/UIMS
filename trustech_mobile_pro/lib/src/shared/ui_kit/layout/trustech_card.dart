import 'package:flutter/material.dart';

import '../../utils/theme_helper.dart';

/// A flat, bordered surface used to group content. Adapts its background and
/// border to the active brightness via [ThemeHelper].
class TrustechCard extends StatelessWidget {
  const TrustechCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.cCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cBorder),
      ),
      child: child,
    );

    return Padding(
      padding: margin,
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onTap,
                child: content,
              ),
            ),
    );
  }
}
