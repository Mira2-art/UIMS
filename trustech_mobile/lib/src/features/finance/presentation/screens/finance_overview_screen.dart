import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/ui_kit/ui_kit.dart';
import '../../../../shared/utils/theme_helper.dart';
import '../../providers/finance_providers.dart';

class FinanceOverviewScreen extends ConsumerWidget {
  const FinanceOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(financeOverviewProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppHeaderBar.home(
        title: 'Finance',
        avatarName: 'John Doe', // TODO(backend): get from user provider
        onNotification: () => context.push('/notifications'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deadline Alert
            _DeadlineAlert(
              title: 'Upcoming Deadline',
              message:
                  'Semester tuition balance is due by ${DateFormat('EEEE, MMM d').format(overview.nextDueDate)}.',
            ),
            const SizedBox(height: 24),

            // Total Balance Card
            _TotalBalanceCard(
              balance: overview.totalBalance,
              dueDate: overview.nextDueDate,
            ),
            const SizedBox(height: 24),

            // Quick Links
            const _QuickLinks(),
            const SizedBox(height: 24),

            // Semester Breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeader(
                  title: 'Current Semester',
                ),
                Text(
                  'Fall 2023',
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InfoListCard(
              children: overview.recentCharges.map((charge) {
                return InfoListRow(
                  title: charge.title,
                  subtitle: charge.category,
                  icon: _getIconForCategory(charge.category),
                  trailingText: NumberFormat.currency(symbol: '\$').format(charge.amount),
                  iconAccent: charge.amount < 0 ? cs.primary : null,
                  onTap: () => context.push('/finance/charges/${charge.id}'),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    if (category.contains('Undergraduate')) return Icons.school_outlined;
    if (category.contains('Computer Science')) return Icons.biotech_outlined;
    if (category.contains('Library')) return Icons.menu_book_outlined;
    if (category.contains('Applied Credit')) return Icons.verified_outlined;
    return Icons.receipt_long_outlined;
  }
}

class _DeadlineAlert extends StatelessWidget {
  const _DeadlineAlert({required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final secondary = cs.secondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: secondary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning, color: secondary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalBalanceCard extends StatelessWidget {
  const _TotalBalanceCard({required this.balance, required this.dueDate});
  final double balance;
  final DateTime dueDate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TrustechCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL OUTSTANDING',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(symbol: '\$').format(balance),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: cs.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: cs.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next payment due',
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                DateFormat('MMM d, yyyy').format(dueDate),
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.cBorder,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.66,
              child: Container(
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TrustechButton(
            label: 'Pay Now',
            icon: Icons.payments_outlined,
            onPressed: () {
              // TODO(backend): integrate payment gateway
            },
          ),
        ],
      ),
    );
  }
}

class _QuickLinks extends StatelessWidget {
  const _QuickLinks();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _QuickLinkCard(
          title: 'All Charges',
          icon: Icons.receipt_long_outlined,
          color: Theme.of(context).colorScheme.primary,
          fullWidth: true,
          onTap: () => context.push('/finance/charges'),
        ),
        _QuickLinkCard(
          title: 'Payments',
          icon: Icons.history,
          color: Theme.of(context).colorScheme.tertiary,
          onTap: () => context.push('/finance/payments'),
        ),
        _QuickLinkCard(
          title: 'Scholarships',
          icon: Icons.workspace_premium_outlined,
          color: Theme.of(context).colorScheme.secondary,
          onTap: () => context.push('/finance/scholarships'),
        ),
      ],
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  const _QuickLinkCard({
    required this.title,
    required this.icon,
    required this.color,
    this.fullWidth = false,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final bool fullWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (fullWidth) {
      return TrustechCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.outline),
          ],
        ),
      );
    }

    return TrustechCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
