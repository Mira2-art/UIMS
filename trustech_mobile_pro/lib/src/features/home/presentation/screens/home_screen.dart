import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/shell/presentation/staff_drawer.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

// Roles: all staff (role-aware dashboard). Tab root.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      drawer: const StaffDrawer(selectedRoute: '/home'),
      appBar: AppHeaderBar.menu(
        title: 'Trustech Staff Pro',
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: TrustechAvatar(name: 'Marcus Webb', radius: 16),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          // Verify-email banner (non-blocking) — TODO(backend:) show when email_verified == false.
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: cs.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Please verify your email address',
                          style: TrustechTypography.bodyMedium
                              .copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
                      Text('Check your inbox to unlock all features.',
                          style: TrustechTypography.caption
                              .copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/verify-email'),
                  child: const Text('Resend'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Quick Actions'),
          const SizedBox(height: 8),
          Row(
            children: [
              _QuickAction(
                icon: Icons.fact_check_outlined,
                label: 'Mark Attendance',
                onTap: () => context.push('/courses'),
              ),
              const SizedBox(width: 12),
              _QuickAction(
                icon: Icons.payments_outlined,
                label: 'Record Payment',
                accent: cs.secondary,
                onTap: () => context.push('/finance/payments/new'),
              ),
              const SizedBox(width: 12),
              _QuickAction(
                icon: Icons.campaign_outlined,
                label: 'Post Announcement',
                accent: cs.tertiary,
                onTap: () => context.push('/announcements/compose'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Finance snapshot — TODO(backend:) GET finance summary.
          StatCard(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Outstanding Balances',
            value: '\$12,480',
            accent: cs.secondary,
          ),
          const SizedBox(height: 20),
          SectionHeader(
            title: "Today's Classes",
            actionLabel: 'View All',
            onAction: () => context.push('/courses'),
          ),
          const SizedBox(height: 4),
          InfoListCard(
            children: [
              InfoListRow(
                title: 'Advanced Algorithms',
                subtitle: 'CS-401 · 09:00 – 10:30 · Science Wing · 24 enrolled',
                icon: Icons.menu_book_outlined,
                showChevron: true,
                onTap: () => context.push('/courses/cs401'),
              ),
              InfoListRow(
                title: 'Data Structures',
                subtitle: 'CS-202 · 13:00 – 14:30 · Hall B · 32 enrolled',
                icon: Icons.menu_book_outlined,
                showChevron: true,
                onTap: () => context.push('/courses/cs202'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionHeader(
            title: 'Pending Grading',
            actionLabel: 'Grade',
            onAction: () => context.push('/courses/cs401/gradebook'),
          ),
          const SizedBox(height: 4),
          InfoListCard(
            children: [
              InfoListRow(
                title: 'Final Year Project Submissions',
                subtitle: 'Due today · 14 remaining',
                icon: Icons.assignment_outlined,
                trailing: const StatusChip(label: '14', kind: StatusKind.warning),
                onTap: () => context.push('/courses/cs401/gradebook'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final a = accent ?? cs.primary;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: TrustechCard(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: a.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: a, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TrustechTypography.caption.copyWith(color: cs.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
