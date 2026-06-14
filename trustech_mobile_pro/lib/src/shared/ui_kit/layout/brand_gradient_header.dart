import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Teal → dark-teal brand gradient surface used for hero areas (Welcome screen,
/// CTA bands). White content sits on top.
class BrandGradientHeader extends StatelessWidget {
  const BrandGradientHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.height,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? height;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [TrustechColors.primary, Color(0xFF2D5A68)],
        ),
      ),
      child: child,
    );
  }
}
