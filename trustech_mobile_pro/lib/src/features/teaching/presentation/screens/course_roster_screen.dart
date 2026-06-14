// Roles: LECTURER
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_colors.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/teaching/data/mock/teaching_mock.dart';
import 'package:trustech_mobile_pro/src/features/teaching/providers/teaching_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class CourseRosterScreen extends ConsumerWidget {
  const CourseRosterScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(teachingCourseProvider(courseId));
    final roster = ref.watch(courseRosterProvider(courseId));
    final cs = Theme.of(context).colorScheme;
    final atRisk = roster
        .where((student) => student.standing != RosterStanding.good)
        .length;

    return Scaffold(
      appBar: AppHeaderBar.back(
        title: '${course?.code ?? 'Course'} Roster',
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO(backend): invite/add student to course roster.
        },
        child: const Icon(Icons.person_add_alt_1_outlined),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Search Students',
              style: TrustechTypography.caption.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            const _SearchBox(label: 'Name or Matric Number...'),
            const SizedBox(height: 14),
            TrustechCard(
              child: Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.groups_2_outlined,
                      label: 'Enrolled',
                      value: roster.length.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.warning_amber_outlined,
                      label: 'At Risk',
                      value: atRisk.toString(),
                      accent: atRisk == 0
                          ? TrustechColors.success
                          : cs.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SectionHeader(
              title: '${roster.length} Students',
              actionLabel: 'Sort',
              onAction: () {},
            ),
            ...roster.map((student) => _RosterRow(student: student)),
            const SizedBox(height: 72),
          ],
        ),
      ),
    );
  }
}

class _RosterRow extends StatelessWidget {
  const _RosterRow({required this.student});

  final CourseRosterStudent student;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TrustechCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          TrustechAvatar(name: student.name, radius: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TrustechTypography.h3.copyWith(color: cs.onSurface),
                ),
                Text(
                  '${student.matricNo} · ${student.program}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TrustechTypography.caption.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusChip(
            label: student.standing == RosterStanding.good
                ? _letter(student.currentScore)
                : 'At Risk',
            kind: _kind(student),
          ),
          Icon(Icons.chevron_right, color: cs.outline),
        ],
      ),
    );
  }

  StatusKind _kind(CourseRosterStudent student) {
    if (student.standing == RosterStanding.probation) return StatusKind.error;
    if (student.standing == RosterStanding.watchlist) return StatusKind.warning;
    return StatusKind.success;
  }

  // Final-grade letter from the combined score (Trustech CA/30 + EXAM/70 scale).
  String _letter(double score) {
    if (score >= 96) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B+';
    if (score >= 60) return 'B';
    if (score >= 55) return 'C+';
    if (score >= 50) return 'C';
    if (score >= 45) return 'D+';
    if (score >= 40) return 'D';
    return 'F';
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: cs.outline),
          const SizedBox(width: 12),
          Text(
            label,
            style: TrustechTypography.bodyLarge.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
