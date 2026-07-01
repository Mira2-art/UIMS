import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

/// One datum for [TrustechBarChart] / [TrustechDonut].
@immutable
class ChartDatum {
  const ChartDatum({required this.label, required this.value, this.color});
  final String label;
  final double value;
  final Color? color;
}

const List<Color> _palette = [
  TrustechColors.chart1,
  TrustechColors.chart2,
  TrustechColors.chart3,
  TrustechColors.chart4,
  TrustechColors.chart5,
];

/// Lightweight vertical bar chart (no external dependency). For finance/admin
/// reports. Bars scale to the max value; labels + values render beneath.
class TrustechBarChart extends StatelessWidget {
  const TrustechBarChart({
    super.key,
    required this.data,
    this.comparison,
    this.height = 180,
    this.primaryLabel,
    this.comparisonLabel,
  });

  final List<ChartDatum> data;

  /// Optional second series (same labels/length) → grouped bars + a legend.
  final List<ChartDatum>? comparison;
  final double height;
  final String? primaryLabel;
  final String? comparisonLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cmp = comparison;
    final hasCmp = cmp != null && cmp.isNotEmpty;
    final values = <double>[
      ...data.map((d) => d.value),
      if (hasCmp) ...cmp.map((d) => d.value),
    ];
    final maxV = values.isEmpty
        ? 1.0
        : values.reduce(math.max).clamp(1, double.infinity);

    final chart = SizedBox(
      height: hasCmp ? height - 28 : height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < data.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: FractionallySizedBox(
                              heightFactor: (data[i].value / maxV).clamp(0.0, 1.0),
                              alignment: Alignment.bottomCenter,
                              child: _barBox(data[i].color ?? _palette[0]),
                            ),
                          ),
                          if (hasCmp && i < cmp.length) ...[
                            const SizedBox(width: 3),
                            Expanded(
                              child: FractionallySizedBox(
                                heightFactor: (cmp[i].value / maxV).clamp(0.0, 1.0),
                                alignment: Alignment.bottomCenter,
                                child: _barBox(cmp[i].color ?? _palette[1]),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data[i].label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TrustechTypography.caption
                          .copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    if (!hasCmp) return chart;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LegendDot(color: _palette[0], label: primaryLabel ?? 'Actual'),
            const SizedBox(width: 16),
            _LegendDot(color: _palette[1], label: comparisonLabel ?? 'Projected'),
          ],
        ),
        const SizedBox(height: 12),
        chart,
      ],
    );
  }

  static Widget _barBox(Color color) => Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      );
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Donut chart with a centered total + side legend.
class TrustechDonut extends StatelessWidget {
  const TrustechDonut({super.key, required this.data, this.size = 140, this.centerLabel});

  final List<ChartDatum> data;
  final double size;
  final String? centerLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colored = [
      for (var i = 0; i < data.length; i++)
        ChartDatum(
          label: data[i].label,
          value: data[i].value,
          color: data[i].color ?? _palette[i % _palette.length],
        ),
    ];
    return Row(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _DonutPainter(colored, cs.surfaceContainerHighest),
            child: Center(
              child: Text(
                centerLabel ?? '',
                textAlign: TextAlign.center,
                style: TrustechTypography.h3.copyWith(color: cs.onSurface),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final d in colored)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: d.color, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(d.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant)),
                      ),
                      Text(d.value.toStringAsFixed(0),
                          style: TrustechTypography.caption
                              .copyWith(color: cs.onSurface, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.data, this.trackColor);
  final List<ChartDatum> data;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2;
    const stroke = 18.0;
    final ring = Rect.fromCircle(center: center, radius: radius - stroke / 2);
    final total = data.fold<double>(0, (s, d) => s + d.value);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = trackColor;
    canvas.drawCircle(center, radius - stroke / 2, track);

    if (total <= 0) return;
    var start = -math.pi / 2;
    for (final d in data) {
      final sweep = (d.value / total) * 2 * math.pi;
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt
        ..color = d.color ?? TrustechColors.primary;
      canvas.drawArc(ring, start, sweep, false, p);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.data != data;
}
