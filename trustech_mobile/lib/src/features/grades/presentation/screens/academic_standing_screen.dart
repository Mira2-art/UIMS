import 'package:flutter/material.dart';

import 'package:trustech_mobile/src/core/constants/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile/src/features/grades/data/mock/grades_mock.dart';
import 'package:trustech_mobile/src/features/grades/providers/grades_providers.dart';
import 'package:trustech_mobile/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile/src/shared/utils/theme_helper.dart';

class AcademicStandingScreen extends ConsumerWidget {
  const AcademicStandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standing = ref.watch(standingProvider);

    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Academic Standing',
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          _StandingHero(standing: standing),
          const SizedBox(height: 16),
          _GraduationProgressCard(standing: standing),
          const SizedBox(height: 16),
          _StandingMetrics(standing: standing),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Historical Standing'),
          const SizedBox(height: 4),
          InfoListCard(
            children: standing.history
                .map((item) => _StandingHistoryRow(item: item))
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _StandingHero extends StatelessWidget {
  const _StandingHero({required this.standing});

  final AcademicStandingSummary standing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.cBorder),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -42,
            bottom: -52,
            child: Icon(
              Icons.auto_graph_outlined,
              size: 138,
              color: cs.primary.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'CUMULATIVE GPA',
                    style: TextStyle(
                      fontFamily: TrustechTypography.fontFamily,
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  StatusChip(
                    label: standing.status.label,
                    kind: _standingKind(standing.status),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ProgressRing(
                    percent: standing.cgpa / 4 * 100,
                    size: 118,
                    strokeWidth: 10,
                    label: standing.cgpa.toStringAsFixed(2),
                    color: cs.primary,
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: cs.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '+${standing.gpaChange.toStringAsFixed(2)} this term',
                              style: TextStyle(
                                fontFamily: TrustechTypography.fontFamily,
                                color: cs.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          standing.cohortRankLabel,
                          style: TextStyle(
                            fontFamily: TrustechTypography.fontFamily,
                            color: cs.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          standing.reason,
                          style: TextStyle(
                            fontFamily: TrustechTypography.fontFamily,
                            color: cs.onSurfaceVariant,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
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

class _GraduationProgressCard extends StatelessWidget {
  const _GraduationProgressCard({required this.standing});

  final AcademicStandingSummary standing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.stars_outlined, color: cs.secondary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exceptional Work',
                  style: TextStyle(
                    fontFamily: TrustechTypography.fontFamily,
                    color: cs.onPrimaryContainer,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You are ${standing.creditsRequired - standing.creditsEarned} credits away from graduation requirements.',
                  style: TextStyle(
                    fontFamily: TrustechTypography.fontFamily,
                    color: cs.onPrimaryContainer.withValues(alpha: 0.86),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                ProgressBar(
                  percent: standing.graduationProgress,
                  color: cs.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StandingMetrics extends StatelessWidget {
  const _StandingMetrics({required this.standing});

  final AcademicStandingSummary standing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.grade_outlined,
                label: 'Term GPA',
                value: standing.currentGpa.toStringAsFixed(2),
                accent: cs.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.workspace_premium_outlined,
                label: 'Credits Earned',
                value: '${standing.creditsEarned}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.school_outlined,
                label: 'Attempted',
                value: '${standing.creditsAttempted}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.flag_outlined,
                label: 'Required',
                value: '${standing.creditsRequired}',
                accent: cs.tertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StandingHistoryRow extends StatelessWidget {
  const _StandingHistoryRow({required this.item});

  final StandingHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return InfoListRow(
      title: item.semester,
      subtitle: 'GPA: ${item.gpa.toStringAsFixed(2)} · ${item.credits} Credits',
      icon: Icons.calendar_today_outlined,
      trailing: StatusChip(
        label: item.status.label,
        kind: _standingKind(item.status),
      ),
    );
  }
}

StatusKind _standingKind(StandingStatus status) {
  switch (status) {
    case StandingStatus.goodStanding:
    case StandingStatus.deansList:
      return StatusKind.success;
    case StandingStatus.probation:
      return StatusKind.warning;
  }
}
