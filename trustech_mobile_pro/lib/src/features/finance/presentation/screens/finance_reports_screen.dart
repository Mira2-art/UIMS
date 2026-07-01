// Roles: BURSAR (FINANCE: manage)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_colors.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class FinanceReportsScreen extends ConsumerWidget {
  const FinanceReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    final barData = [
      const ChartDatum(label: 'SEP', value: 160),
      const ChartDatum(label: 'OCT', value: 190),
      const ChartDatum(label: 'NOV', value: 140),
      const ChartDatum(label: 'DEC', value: 220),
      const ChartDatum(label: 'JAN', value: 210),
      const ChartDatum(label: 'FEB', value: 250),
    ];

    final projectedData = [
      const ChartDatum(label: 'SEP', value: 150),
      const ChartDatum(label: 'OCT', value: 175),
      const ChartDatum(label: 'NOV', value: 165),
      const ChartDatum(label: 'DEC', value: 205),
      const ChartDatum(label: 'JAN', value: 230),
      const ChartDatum(label: 'FEB', value: 245),
    ];

    final donutData = [
      const ChartDatum(label: 'Tuition', value: 60),
      const ChartDatum(label: 'Transport', value: 25),
      const ChartDatum(label: 'Other', value: 15),
    ];

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Finance Reports'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Financial Reports',
                    style: TrustechTypography.displayLarge.copyWith(color: cs.onSurface),
                  ),
                ),
                TrustechButton(
                  label: 'Export',
                  icon: Icons.download,
                  expand: false,
                  height: 40,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),

            // KPI headline cards
            const Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'TOTAL COLLECTIONS',
                    value: '\$1.24M',
                    icon: Icons.trending_up,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'OUTSTANDING',
                    value: '\$342.5K',
                    icon: Icons.warning_amber_outlined,
                    accent: TrustechColors.destructive,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: StatCard(
                    label: 'RECOVERY RATE',
                    value: '92.4%',
                    icon: Icons.percent,
                    accent: TrustechColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'FEE STRUCTURES',
                    value: '14',
                    icon: Icons.receipt_long_outlined,
                    accent: cs.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Collection Trends (6 Months)'),
            const SizedBox(height: 16),
            TrustechCard(
              padding: const EdgeInsets.all(16),
              child: TrustechBarChart(
                data: barData,
                comparison: projectedData,
                primaryLabel: 'Actual',
                comparisonLabel: 'Projected',
              ),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Collection Category'),
            const SizedBox(height: 16),
            TrustechCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TrustechDonut(data: donutData, centerLabel: 'Top\nTuition'),
                  const SizedBox(height: 16),
                  ...donutData.asMap().entries.map((e) {
                    final colors = [cs.primary, cs.secondary, cs.tertiary];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors[e.key % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              e.value.label,
                              style: TrustechTypography.bodySmall
                                  .copyWith(color: cs.onSurfaceVariant),
                            ),
                          ),
                          Text(
                            '${e.value.value.toStringAsFixed(0)}%',
                            style: TrustechTypography.label.copyWith(color: cs.onSurface),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SectionHeader(title: 'Recent Activity', actionLabel: 'View Ledger', onAction: () {}),
            const SizedBox(height: 8),
            const InfoListCard(
              children: [
                InfoListRow(
                  title: 'Aria Montgomery',
                  subtitle: '#TXN-8821 · Tuition Q3',
                  trailingText: '\$2,500',
                  icon: Icons.receipt_long_outlined,
                ),
                InfoListRow(
                  title: 'Liam Jenkins',
                  subtitle: '#TXN-8819 · Bus Fee',
                  trailingText: '\$150',
                  icon: Icons.receipt_long_outlined,
                ),
                InfoListRow(
                  title: 'Isabella Ross',
                  subtitle: '#TXN-8815 · Lab Supplies',
                  trailingText: '\$320',
                  icon: Icons.receipt_long_outlined,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
