import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/ui_kit/ui_kit.dart';
import '../../providers/finance_providers.dart';
import '../../data/mock/finance_mock.dart';

class ChargesScreen extends ConsumerWidget {
  const ChargesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charges = ref.watch(chargesProvider);
    final overview = ref.watch(financeOverviewProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Charges',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          const Padding(
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
            // Outstanding Balance Summary
            _BalanceSummary(
              balance: overview.totalBalance,
              isOverdue: true, // TODO(backend): determine from charges
            ),
            const SizedBox(height: 24),

            // Filters & Sort
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Financial Log',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                Row(
                  children: [
                    _FilterButton(
                      label: 'Filter',
                      icon: Icons.filter_list,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _FilterButton(
                      label: 'Sort',
                      icon: Icons.swap_vert,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Charges List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: charges.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final charge = charges[index];
                return _ChargeCard(
                  charge: charge,
                  onTap: () => context.push('/finance/charges/${charge.id}'),
                );
              },
            ),

            const SizedBox(height: 24),
            // Footer info
            Center(
              child: Opacity(
                opacity: 0.5,
                child: Column(
                  children: [
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Showing ${charges.length} of 12 charges',
                      style: const TextStyle(fontSize: 12),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View older history'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.credit_card),
        label: const Text('Pay Balance'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
    );
  }
}

class _BalanceSummary extends StatelessWidget {
  const _BalanceSummary({required this.balance, required this.isOverdue});
  final double balance;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TrustechCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OUTSTANDING BALANCE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat.currency(symbol: '\$').format(balance),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                  letterSpacing: -0.5,
                ),
              ),
              if (isOverdue)
                const StatusChip(
                  label: 'OVERDUE',
                  kind: StatusKind.error,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: cs.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChargeCard extends StatelessWidget {
  const _ChargeCard({required this.charge, required this.onTap});
  final Charge charge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TrustechCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(charge.status, cs).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(charge.status),
              color: _getStatusColor(charge.status, cs),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  charge.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  'Due ${DateFormat('MMM dd, yyyy').format(charge.dueDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat.currency(symbol: '\$').format(charge.amount),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: charge.status == ChargeStatus.outstanding ? cs.error : cs.onSurface,
                ),
              ),
              StatusChip(
                label: charge.status.label,
                kind: _getStatusKind(charge.status),
              ),
            ],
          ),
        ],
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

  Color _getStatusColor(ChargeStatus status, ColorScheme cs) {
    switch (status) {
      case ChargeStatus.paid:
        return cs.primary;
      case ChargeStatus.partial:
        return cs.secondary;
      case ChargeStatus.outstanding:
        return cs.error;
      case ChargeStatus.waived:
        return cs.outline;
    }
  }

  IconData _getStatusIcon(ChargeStatus status) {
    switch (status) {
      case ChargeStatus.paid:
        return Icons.check_circle_outlined;
      case ChargeStatus.partial:
        return Icons.history_edu_outlined;
      case ChargeStatus.outstanding:
        return Icons.payments_outlined;
      case ChargeStatus.waived:
        return Icons.description_outlined;
    }
  }
}
