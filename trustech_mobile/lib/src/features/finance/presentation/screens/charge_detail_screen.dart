import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/ui_kit/ui_kit.dart';
import '../../providers/finance_providers.dart';
import '../../data/mock/finance_mock.dart';

class ChargeDetailScreen extends ConsumerWidget {
  const ChargeDetailScreen({super.key, required this.chargeId});
  final String chargeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charge = ref.watch(chargeDetailProvider(chargeId));
    final cs = Theme.of(context).colorScheme;

    if (charge == null) {
      return const TrustechScaffold(
        title: 'Charge Detail',
        body: TrustechEmptyState(
          title: 'Charge Not Found',
          message: 'The requested charge could not be found.',
        ),
      );
    }

    return Scaffold(
      appBar: const AppHeaderBar.back(
        title: 'Charge Detail',
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: TrustechAvatar(radius: 16),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusChip(
                  label: charge.semester.toUpperCase(),
                  kind: StatusKind.info,
                ),
                StatusChip(
                  label: charge.status.label,
                  kind: _getStatusKind(charge.status),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              charge.title,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Reference: TRU-2024-${chargeId.padLeft(7, '0')}',
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Details Card
            TrustechCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _DetailItem(
                          label: 'DATE ISSUED',
                          value: DateFormat('MMM dd, yyyy').format(DateTime(2023, 8, 15)),
                        ),
                      ),
                      Expanded(
                        child: _DetailItem(
                          label: 'DUE DATE',
                          value: DateFormat('MMM dd, yyyy').format(charge.dueDate),
                          valueColor: charge.status == ChargeStatus.outstanding ? cs.error : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'ITEMIZED BREAKDOWN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _BreakdownRow(
                    title: 'Undergraduate Tuition',
                    subtitle: 'Course Credits: 18 units',
                    amount: charge.amount * 0.9,
                  ),
                  const SizedBox(height: 16),
                  _BreakdownRow(
                    title: 'Student Service Fees',
                    subtitle: 'Campus Amenities & Tech Access',
                    amount: charge.amount * 0.07,
                  ),
                  const SizedBox(height: 16),
                  _BreakdownRow(
                    title: 'International Insurance',
                    subtitle: 'Comprehensive Plan B',
                    amount: charge.amount * 0.03,
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            NumberFormat.currency(symbol: '\$').format(charge.amount),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: cs.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Incl. 5% Student Tax',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            TrustechButton(
              label: 'Make Payment',
              icon: Icons.payments,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            TrustechButton(
              label: 'Download Invoice (PDF)',
              icon: Icons.download,
              variant: TrustechButtonVariant.outline,
              onPressed: () {},
            ),
            const SizedBox(height: 24),

            // Note Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: cs.secondary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Payments made after the due date may incur a late fee of 1.5% per month. If you are experiencing financial hardship, please contact the Student Finance Office.',
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Payment History (if any)
            if (charge.history != null && charge.history!.isNotEmpty) ...[
              const SizedBox(height: 32),
              const SectionHeader(title: 'Payment History'),
              const SizedBox(height: 12),
              InfoListCard(
                children: charge.history!.map((payment) {
                  return InfoListRow(
                    title: payment.method,
                    subtitle: DateFormat('MMM dd, yyyy').format(payment.date),
                    trailingText: NumberFormat.currency(symbol: '\$').format(payment.amount),
                    icon: Icons.history,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  StatusKind _getStatusKind(ChargeStatus status) {
    switch (status) {
      case ChargeStatus.paid:
        return StatusKind.success;
      case ChargeStatus.partial:
        return StatusKind.warning;
      case ChargeStatus.outstanding:
        return StatusKind.error;
      case ChargeStatus.waived:
        return StatusKind.neutral;
    }
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.label,
    required this.value,
    this.valueColor,
  });
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: valueColor ?? cs.onSurface,
          ),
        ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.title,
    required this.subtitle,
    required this.amount,
  });
  final String title;
  final String subtitle;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          NumberFormat.currency(symbol: '\$').format(amount),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}
