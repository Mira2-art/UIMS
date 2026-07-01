import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_typography.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../shared/ui_kit/ui_kit.dart';
import '../../../../shared/utils/money.dart';
import '../../providers/finance_providers.dart';
import '../../data/mock/finance_mock.dart';

class ChargesScreen extends ConsumerWidget {
  const ChargesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chargesAsync = ref.watch(chargesProvider);
    final overviewAsync = ref.watch(financeOverviewProvider);
    final cs = Theme.of(context).colorScheme;

    if (!chargesAsync.hasValue || !overviewAsync.hasValue) {
      final err = chargesAsync.error ?? overviewAsync.error;
      return Scaffold(
        appBar: const AppHeaderBar.back(title: 'Charges'),
        body: err != null
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: ErrorStateCard(
                  message: friendlyError(err),
                  onRetry: () {
                    ref.invalidate(chargesProvider);
                    ref.invalidate(financeOverviewProvider);
                  },
                ),
              )
            : const TrustechLoader(),
      );
    }
    final charges = chargesAsync.requireValue;
    final overview = overviewAsync.requireValue;

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
                  style: TrustechTypography.h3.copyWith(
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
            if (charges.isEmpty)
              const TrustechEmptyState(
                title: 'No charges yet',
                message: 'You have no fee charges at the moment.',
                icon: Icons.receipt_long_outlined,
              )
            else
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
                      style: TrustechTypography.caption,
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
            style: TrustechTypography.overline.copyWith(
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
                formatFcfa(balance),
                style: TrustechTypography.displayLarge.copyWith(
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
              style: TrustechTypography.caption.copyWith(
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
                  style: TrustechTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  'Due ${DateFormat('MMM dd, yyyy').format(charge.dueDate)}',
                  style: TrustechTypography.caption.copyWith(
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
                formatFcfa(charge.amount),
                style: TrustechTypography.h3.copyWith(
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
