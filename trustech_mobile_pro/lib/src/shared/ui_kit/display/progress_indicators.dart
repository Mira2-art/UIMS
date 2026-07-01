import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

/// Picks an accent by threshold: ≥[good] green, ≥[warn] amber, else red.
Color thresholdColor(double percent, {double good = 75, double warn = 50}) {
  if (percent >= good) return TrustechColors.success;
  if (percent >= warn) return TrustechColors.secondary;
  return TrustechColors.destructive;
}

/// Circular progress ring with a centered label. Used for attendance rate, GPA,
/// etc. [percent] is 0–100. Color follows [thresholdColor] unless [color] given.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.percent,
    this.size = 96,
    this.strokeWidth = 8,
    this.label,
    this.color,
  });

  final double percent;
  final double size;
  final double strokeWidth;
  final String? label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = color ?? thresholdColor(percent);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: (percent.clamp(0, 100)) / 100,
              strokeWidth: strokeWidth,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(c),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            label ?? '${percent.toStringAsFixed(0)}%',
            style: TrustechTypography.h1.copyWith(fontSize: size * 0.22, fontWeight: FontWeight.w800, color: cs.onSurface),
          ),
        ],
      ),
    );
  }
}

/// Linear progress bar with threshold color.
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.percent, this.height = 8, this.color});

  final double percent;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = color ?? thresholdColor(percent);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: (percent.clamp(0, 100)) / 100,
        minHeight: height,
        backgroundColor: cs.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation(c),
      ),
    );
  }
}
