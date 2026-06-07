import 'package:flutter/material.dart';

import 'package:trustech_mobile/src/core/constants/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile/src/features/courses/data/mock/courses_mock.dart';
import 'package:trustech_mobile/src/features/courses/providers/courses_providers.dart';
import 'package:trustech_mobile/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile/src/shared/utils/theme_helper.dart';

class CourseAttendanceScreen extends ConsumerWidget {
  const CourseAttendanceScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(courseDetailProvider(courseId));
    final summary = ref.watch(courseAttendanceProvider(courseId));

    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Attendance',
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: summary == null
          ? TrustechEmptyState(
              title: 'Attendance unavailable',
              message: 'No mock attendance records exist for this course yet.',
              icon: Icons.fact_check_outlined,
              actionLabel: 'Back to Course',
              onAction: () => context.pop(),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: [
                _AttendanceHero(course: course, summary: summary),
                const SizedBox(height: 16),
                _AttendanceStats(summary: summary),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Class Records'),
                const SizedBox(height: 4),
                InfoListCard(
                  children: summary.records
                      .map((record) => _AttendanceRecordRow(record: record))
                      .toList(growable: false),
                ),
                const SizedBox(height: 18),
                TrustechButton(
                  label: 'Request Correction',
                  icon: Icons.edit_note_outlined,
                  variant: TrustechButtonVariant.outline,
                  onPressed: () {
                    // TODO(backend): submit attendance correction request.
                    AppSnackbar.info(
                      context,
                      'Attendance correction request flow coming soon.',
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class _AttendanceHero extends StatelessWidget {
  const _AttendanceHero({required this.course, required this.summary});

  final CourseDetail? course;
  final CourseAttendanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = summary.isBelowRequirement ? cs.secondary : cs.primary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.cBorder),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProgressRing(
                percent: summary.percent,
                size: 112,
                strokeWidth: 10,
                color: accent,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusChip(
                      label: summary.isBelowRequirement
                          ? 'Below Requirement'
                          : 'Requirement Met',
                      kind: summary.isBelowRequirement
                          ? StatusKind.warning
                          : StatusKind.success,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      course?.code ?? 'Course Attendance',
                      style: TextStyle(
                        fontFamily: TrustechTypography.fontFamily,
                        color: cs.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course?.title ?? 'Attendance Summary',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: TrustechTypography.fontFamily,
                        color: cs.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Minimum required attendance is ${summary.requiredPercent.toStringAsFixed(0)}%.',
                      style: TextStyle(
                        fontFamily: TrustechTypography.fontFamily,
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (summary.isBelowRequirement) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: accent, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You are currently below the attendance threshold. Attend the next sessions or contact your lecturer if a record is incorrect.',
                      style: TextStyle(
                        fontFamily: TrustechTypography.fontFamily,
                        color: cs.onSurface,
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AttendanceStats extends StatelessWidget {
  const _AttendanceStats({required this.summary});

  final CourseAttendanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.check_circle_outline,
                label: 'Present',
                value: summary.present.toString(),
                accent: cs.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.schedule_outlined,
                label: 'Late',
                value: summary.late.toString(),
                accent: cs.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.cancel_outlined,
                label: 'Absent',
                value: summary.absent.toString(),
                accent: cs.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.verified_outlined,
                label: 'Excused',
                value: summary.excused.toString(),
                accent: cs.tertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AttendanceRecordRow extends StatelessWidget {
  const _AttendanceRecordRow({required this.record});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    return InfoListRow(
      title: record.topic,
      subtitle: '${record.dateLabel} · ${record.timeLabel}',
      icon: _statusIcon(record.status),
      iconAccent: _statusAccent(context, record.status),
      trailing: StatusChip(
        label: record.status.label,
        kind: _statusKind(record.status),
      ),
    );
  }
}

IconData _statusIcon(AttendanceRecordStatus status) {
  switch (status) {
    case AttendanceRecordStatus.present:
      return Icons.check_circle_outline;
    case AttendanceRecordStatus.late:
      return Icons.schedule_outlined;
    case AttendanceRecordStatus.absent:
      return Icons.cancel_outlined;
    case AttendanceRecordStatus.excused:
      return Icons.verified_outlined;
  }
}

StatusKind _statusKind(AttendanceRecordStatus status) {
  switch (status) {
    case AttendanceRecordStatus.present:
      return StatusKind.success;
    case AttendanceRecordStatus.late:
      return StatusKind.warning;
    case AttendanceRecordStatus.absent:
      return StatusKind.error;
    case AttendanceRecordStatus.excused:
      return StatusKind.info;
  }
}

Color _statusAccent(BuildContext context, AttendanceRecordStatus status) {
  final cs = Theme.of(context).colorScheme;
  switch (status) {
    case AttendanceRecordStatus.present:
      return cs.primary;
    case AttendanceRecordStatus.late:
      return cs.secondary;
    case AttendanceRecordStatus.absent:
      return cs.error;
    case AttendanceRecordStatus.excused:
      return cs.tertiary;
  }
}
