// Roles: BURSAR (FINANCE: manage)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile_pro/src/features/finance/providers/finance_providers.dart';
import 'package:trustech_mobile_pro/src/features/finance/data/mock/finance_mock.dart';

class ChargeDetailScreen extends ConsumerWidget {
  const ChargeDetailScreen({super.key, required this.chargeId});

  final String chargeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charge = ref.watch(chargeDetailProvider(chargeId));

    if (charge == null) {
      return const TrustechScaffold(
        title: 'Charge Detail',
        body: Center(child: Text('Charge not found')),
      );
    }

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Charge Detail'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Profile Card
            _StudentHeader(charge: charge),
            const SizedBox(height: 24),

            // Main Content Bento Grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _ItemizedCard(items: charge.items, total: charge.amount),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _StatusSummary(charge: charge),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Payment History
            _HistoryCard(history: charge.history),
            const SizedBox(height: 24),

            // Audit Log
            const _AuditLogContext(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _StudentHeader extends StatelessWidget {
  const _StudentHeader({required this.charge});
  final Charge charge;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TrustechCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          TrustechAvatar(name: charge.studentName, radius: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STUDENT ID: #${charge.studentId}',
                  style: TrustechTypography.overline.copyWith(color: cs.outline),
                ),
                Text(
                  charge.studentName,
                  style: TrustechTypography.h2.copyWith(color: cs.onSurface),
                ),
                Text(
                  'Grade 11 - Science & Math Cluster',
                  style: TrustechTypography.bodySmall.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          StatusChip(
            label: charge.status.label,
            kind: _getKind(charge.status),
          ),
        ],
      ),
    );
  }

  StatusKind _getKind(ChargeStatus status) {
    switch (status) {
      case ChargeStatus.paid:
        return StatusKind.success;
      case ChargeStatus.overdue:
        return StatusKind.error;
      case ChargeStatus.partial:
        return StatusKind.warning;
      case ChargeStatus.pending:
        return StatusKind.neutral;
    }
  }
}

class _StatusSummary extends StatelessWidget {
  const _StatusSummary({required this.charge});
  final Charge charge;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PAYMENT STATUS',
            style: TrustechTypography.overline.copyWith(color: cs.outline),
          ),
          const SizedBox(height: 16),
          _StatusItem(label: 'Total Due', value: charge.amount),
          const SizedBox(height: 12),
          _StatusItem(label: 'Total Paid', value: charge.paidAmount, color: cs.secondary),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'REMAINING BALANCE',
            style: TrustechTypography.caption.copyWith(fontWeight: FontWeight.bold, color: cs.onSurfaceVariant),
          ),
          Text(
            '\$${charge.balance.toStringAsFixed(2)}',
            style: TrustechTypography.displayLarge.copyWith(color: cs.error, fontSize: 24),
          ),
          const SizedBox(height: 24),
          TrustechButton(
            label: 'Remind',
            icon: Icons.notifications_outlined,
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          TrustechButton(
            label: 'Edit',
            variant: TrustechButtonVariant.outline,
            icon: Icons.edit_outlined,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  const _StatusItem({required this.label, required this.value, this.color});
  final String label;
  final double value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TrustechTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: TrustechTypography.h2.copyWith(color: color ?? Theme.of(context).colorScheme.onSurface, fontSize: 18),
        ),
      ],
    );
  }
}

class _ItemizedCard extends StatelessWidget {
  const _ItemizedCard({required this.items, required this.total});
  final List<ChargeItem> items;
  final double total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TrustechCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              border: Border(bottom: BorderSide(color: cs.outlineVariant)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Itemized Breakdown', style: TrustechTypography.h3),
                TextButton(onPressed: () {}, child: const Text('Edit Items')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: TrustechTypography.label),
                              Text(item.description,
                                  style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant)),
                            ],
                          ),
                          Text('\$${item.amount.toStringAsFixed(2)}', style: TrustechTypography.bodyLarge),
                        ],
                      ),
                    )),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Charge Amount', style: TrustechTypography.h3),
                    Text('\$${total.toStringAsFixed(2)}', style: TrustechTypography.h2.copyWith(color: cs.primary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.history});
  final List<PaymentHistory> history;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TrustechCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              border: Border(bottom: BorderSide(color: cs.outlineVariant)),
            ),
            child: const Text('Payment History', style: TrustechTypography.h3),
          ),
          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No payments recorded yet.')),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = history[index];
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.date, style: TrustechTypography.bodySmall),
                          Text(item.receiptNo, style: TrustechTypography.label.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text(item.method, style: TrustechTypography.bodySmall),
                      Text('\$${item.amount.toStringAsFixed(2)}',
                          style: TrustechTypography.label.copyWith(color: cs.secondary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
          const Divider(height: 1),
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.receipt_long, size: 18),
              label: const Text('Download Statement'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditLogContext extends StatelessWidget {
  const _AuditLogContext();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant, style: BorderStyle.solid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text('AUDIT LOG', style: TrustechTypography.overline.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Charge created by System Admin on Aug 01, 2023',
            style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant),
          ),
          Text(
            'Last updated by Finance Officer on Oct 12, 2023',
            style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
