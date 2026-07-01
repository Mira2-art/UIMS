// Roles: ADMIN (ADMIN: manage)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_colors.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    final barData = [
      const ChartDatum(label: 'MON', value: 85),
      const ChartDatum(label: 'TUE', value: 92),
      const ChartDatum(label: 'WED', value: 78),
      const ChartDatum(label: 'THU', value: 95),
      const ChartDatum(label: 'FRI', value: 88),
    ];

    final donutData = [
      const ChartDatum(label: 'Active', value: 350),
      const ChartDatum(label: 'Suspended', value: 25),
      const ChartDatum(label: 'Pending', value: 40),
    ];

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Admin Portal'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Dashboard', style: TrustechTypography.displayLarge.copyWith(color: cs.onSurface)),
            const SizedBox(height: 24),
            
            // KPI Grid
            const Row(
              children: [
                Expanded(child: StatCard(label: 'TOTAL USERS', value: '415', icon: Icons.people_outline)),
                SizedBox(width: 12),
                Expanded(child: StatCard(label: 'ACTIVE', value: '350', icon: Icons.check_circle_outline, accent: TrustechColors.success)),
              ],
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'System Activity'),
            const SizedBox(height: 16),
            TrustechCard(
              padding: const EdgeInsets.all(16),
              child: TrustechBarChart(data: barData),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'User Distribution'),
            const SizedBox(height: 16),
            TrustechCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TrustechDonut(data: donutData, centerLabel: 'User\nStatus'),
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
                            e.value.value.toStringAsFixed(0),
                            style: TrustechTypography.label
                                .copyWith(color: cs.onSurface),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Quick Actions'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.person_add_alt,
                    label: 'Invite User',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.history,
                    label: 'Audit Logs',
                    onTap: () => context.push('/admin/audit-logs'),
                  ),
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(icon, color: cs.primary),
            const SizedBox(height: 8),
            Text(label, style: TrustechTypography.label.copyWith(color: cs.onSurface)),
          ],
        ),
      ),
    );
  }
}
