import 'package:flutter/material.dart';

import 'package:trustech_mobile/src/core/constants/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile/src/core/auth/session_controller.dart';
import 'package:trustech_mobile/src/core/network/error_mapper.dart';
import 'package:trustech_mobile/src/features/home/data/mock/home_mock.dart';
import 'package:trustech_mobile/src/features/home/providers/home_providers.dart';
import 'package:trustech_mobile/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile/src/shared/utils/theme_helper.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(homeSummaryProvider);
    final summary = summaryAsync.valueOrNull;

    if (summary == null) {
      return Scaffold(
        appBar: AppHeaderBar.home(
          avatarName: ref.watch(sessionProvider).user?.fullName ?? 'Student',
          onNotification: () => context.push('/notifications'),
        ),
        body: summaryAsync.hasError
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: ErrorStateCard(
                  message: friendlyError(summaryAsync.error!),
                  onRetry: () => ref.invalidate(homeSummaryProvider),
                ),
              )
            : const TrustechLoader(),
      );
    }

    return Scaffold(
      appBar: AppHeaderBar.home(
        avatarName: summary.studentName,
        unreadCount: 3,
        onNotification: () => context.push('/notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          _StandingCard(summary: summary),
          const SizedBox(height: 16),
          _QuickActions(
            onTimetable: () => context.push('/home/timetable'),
            onRegistration: () => context.push('/courses/register'),
            onTranscript: () => context.go('/grades'),
          ),
          const SizedBox(height: 16),
          _FinanceBalanceCard(
            balance: summary.outstandingBalance,
            onPayNow: () => context.go('/finance'),
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: "Today's Classes",
            actionLabel: 'See All',
            onAction: () => context.push('/home/timetable'),
          ),
          if (summary.todaysClasses.isEmpty)
            const TrustechEmptyState(
              title: 'No classes today',
              message: 'Your scheduled classes will show here.',
              icon: Icons.event_available_outlined,
            )
          else
            InfoListCard(
              children: [
                for (final item in summary.todaysClasses)
                  InfoListRow(
                    title: '${item.code} · ${item.title}',
                    subtitle: '${item.time} · ${item.venue} · ${item.type}',
                    icon: Icons.calendar_month_outlined,
                    showChevron: true,
                    onTap: () => context.push('/courses/${item.courseId}'),
                  ),
              ],
            ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Announcements'),
          if (summary.announcements.isEmpty)
            const TrustechEmptyState(
              title: 'No announcements yet',
              message: 'New announcements will appear here.',
              icon: Icons.campaign_outlined,
            )
          else
            _AnnouncementScroller(announcements: summary.announcements),
        ],
      ),
    );
  }
}

class _StandingCard extends StatelessWidget {
  const _StandingCard({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TrustechCard(
      padding: const EdgeInsets.all(18),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -38,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cs.secondary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const SizedBox(width: 120, height: 120),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACADEMIC STANDING',
                          style: TextStyle(
                            fontFamily: TrustechTypography.fontFamily,
                            color: cs.onSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              summary.gpa.toStringAsFixed(2),
                              style: TextStyle(
                                fontFamily: TrustechTypography.fontFamily,
                                color: cs.primary,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 7,
                                left: 6,
                              ),
                              child: Text(
                                'GPA',
                                style: TextStyle(
                                  fontFamily: TrustechTypography.fontFamily,
                                  color: cs.onSurfaceVariant,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  StatusChip(label: summary.standing, kind: StatusKind.success),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: context.cBorder),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetaBlock(label: 'Program', value: summary.program),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _MetaBlock(label: 'Level', value: summary.level),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: TrustechTypography.fontFamily,
            color: cs.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: TrustechTypography.fontFamily,
            color: cs.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onTimetable,
    required this.onRegistration,
    required this.onTranscript,
  });

  final VoidCallback onTimetable;
  final VoidCallback onRegistration;
  final VoidCallback onTranscript;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionTile(
            icon: Icons.calendar_month_outlined,
            label: 'Timetable',
            onTap: onTimetable,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionTile(
            icon: Icons.app_registration_outlined,
            label: 'Registration',
            onTap: onRegistration,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionTile(
            icon: Icons.analytics_outlined,
            label: 'Transcript',
            onTap: onTranscript,
          ),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
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
    return TrustechCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: TrustechTypography.fontFamily,
              color: cs.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceBalanceCard extends StatelessWidget {
  const _FinanceBalanceCard({required this.balance, required this.onPayNow});

  final double balance;
  final VoidCallback onPayNow;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: TrustechTypography.fontFamily,
                    color: cs.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Outstanding Balance',
                  style: TextStyle(
                    fontFamily: TrustechTypography.fontFamily,
                    color: cs.onPrimary.withValues(alpha: 0.78),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TrustechButton(
            label: 'Pay Now',
            onPressed: onPayNow,
            variant: TrustechButtonVariant.secondary,
            expand: false,
            height: 44,
          ),
        ],
      ),
    );
  }
}

class _AnnouncementScroller extends StatelessWidget {
  const _AnnouncementScroller({required this.announcements});

  final List<HomeAnnouncement> announcements;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 166,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: announcements.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = announcements[index];
          return SizedBox(
            width: 245,
            child: TrustechCard(
              onTap: () => context.push('/announcements/${item.id}'),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusChip(label: item.category, kind: StatusKind.info),
                  const Spacer(),
                  Icon(Icons.campaign_outlined, color: cs.secondary),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: TrustechTypography.fontFamily,
                      color: cs.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.excerpt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: TrustechTypography.fontFamily,
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
