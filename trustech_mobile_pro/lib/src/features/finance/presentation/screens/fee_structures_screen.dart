// Roles: BURSAR (FINANCE: manage)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile_pro/src/features/finance/providers/finance_providers.dart';
import 'package:trustech_mobile_pro/src/features/finance/data/mock/finance_mock.dart';

class FeeStructuresScreen extends ConsumerWidget {
  const FeeStructuresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fees = ref.watch(feeStructuresProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Finance Portal'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FINANCIAL CONFIGURATION',
              style: TrustechTypography.overline.copyWith(color: cs.primary),
            ),
            const SizedBox(height: 4),
            Text(
              'Fee Structures',
              style: TrustechTypography.displayLarge.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage academic tuition, laboratory fees, and miscellaneous charges across programs.',
              style: TrustechTypography.bodySmall.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),

            // KPI Summary
            const _KpiRow(),
            const SizedBox(height: 24),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Filter fees or programs...',
                prefixIcon: const Icon(Icons.search),
                fillColor: cs.surfaceContainerLow,
              ),
            ),
            const SizedBox(height: 24),

            // Fee List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fees.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _FeeCard(fee: fees[index]);
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Create Fee'),
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: StatCard(label: 'TOTAL ACTIVE', value: '24', icon: Icons.check_circle_outline)),
        SizedBox(width: 8),
        Expanded(child: StatCard(label: 'PROGRAMS', value: '12', icon: Icons.school_outlined)),
        SizedBox(width: 8),
        Expanded(child: StatCard(label: 'PENDING', value: '2', icon: Icons.pending_actions_outlined, accent: Colors.red)),
      ],
    );
  }
}

class _FeeCard extends StatelessWidget {
  const _FeeCard({required this.fee});
  final FeeStructure fee;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TrustechCard(
      onTap: () {},
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIconForFee(fee.title), color: cs.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fee.title,
                  style: TrustechTypography.label.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface),
                ),
                Text(
                  fee.program,
                  style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${fee.amount.toStringAsFixed(0)}',
                style: TrustechTypography.h3.copyWith(color: cs.onSurface),
              ),
              StatusChip(
                label: fee.status.label,
                kind: fee.status == FeeStatus.active ? StatusKind.success : StatusKind.neutral,
              ),
            ],
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, size: 20, color: cs.outline),
        ],
      ),
    );
  }

  IconData _getIconForFee(String title) {
    if (title.contains('Tuition')) return Icons.receipt_long;
    if (title.contains('Lab')) return Icons.biotech;
    if (title.contains('Athletic')) return Icons.stadium;
    return Icons.library_books;
  }
}
