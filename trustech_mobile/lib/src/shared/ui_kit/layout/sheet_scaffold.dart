import 'package:flutter/material.dart';

import '../../../core/constants/app_typography.dart';
import '../../utils/theme_helper.dart';

/// Standard content scaffold for modal bottom sheets: drag grabber, title row,
/// and a body. Pair with `showModalBottomSheet(isScrollControlled: true, ...)`.
class SheetScaffold extends StatelessWidget {
  const SheetScaffold({
    super.key,
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 24),
  });

  final String title;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.cBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              title,
              style: TrustechTypography.h2.copyWith(fontSize: 18, color: cs.onSurface),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
