// Roles: LECTURER
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_colors.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/teaching/data/mock/teaching_mock.dart';
import 'package:trustech_mobile_pro/src/features/teaching/providers/teaching_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class AttendanceSessionsScreen extends ConsumerWidget {
  const AttendanceSessionsScreen({super.key, required this.courseId});
  final String courseId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(teachingCourseProvider(courseId));
    final sessions = ref.watch(attendanceSessionsProvider(courseId));
    final cs = Theme.of(context).colorScheme;
    final avg = sessions.isEmpty
        ? 0
        : sessions.fold<double>(0, (sum, s) => sum + s.attendanceRate) /
              sessions.length;
    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Staff Portal',
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSessionSheet(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AnnouncementBanner(
              message:
                  'Attendance reminder: mark all sessions before grade publication.',
              actionLabel: 'View',
              onAction: () {},
            ),
            const SizedBox(height: 18),
            Text(
              course?.code ?? 'Course',
              style: TrustechTypography.displayLarge.copyWith(
                color: cs.primary,
              ),
            ),
            Text(
              'Attendance Sessions',
              style: TrustechTypography.h2.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TrustechCard(
              child: Row(
                children: [
                  ProgressRing(
                    percent: avg.toDouble(),
                    size: 96,
                    strokeWidth: 9,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OVERALL ATTENDANCE',
                          style: TrustechTypography.overline.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${avg.round()}%',
                          style: TrustechTypography.displayLarge.copyWith(
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          '${sessions.length} sessions tracked',
                          style: TrustechTypography.caption.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SectionHeader(
              title: 'Past Sessions',
              actionLabel: 'View All',
              onAction: () {},
            ),
            ...sessions.map(
              (session) => _SessionCard(courseId: courseId, session: session),
            ),
            const SizedBox(height: 72),
          ],
        ),
      ),
    );
  }

  void _showCreateSessionSheet(BuildContext context) {
    final c = TextEditingController();
    showAppSheet<void>(
      context,
      (ctx) => SheetScaffold(
        title: 'Create attendance session',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TrustechTextField(
              controller: c,
              label: 'Topic',
              hintText: 'e.g. Week 4 - Trees',
              prefixIcon: Icons.topic_outlined,
            ),
            const SizedBox(height: 16),
            TrustechButton(
              label: 'Create session',
              icon: Icons.add,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    ).whenComplete(c.dispose);
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.courseId, required this.session});
  final String courseId;
  final AttendanceSession session;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final open = session.status == 'Open';
    return TrustechCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => context.push('/courses/$courseId/attendance/${session.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  session.title,
                  style: TrustechTypography.h3.copyWith(color: cs.onSurface),
                ),
              ),
              Icon(Icons.more_vert, color: cs.outline),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${session.date} · ${session.time}',
            style: TrustechTypography.caption.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ProgressBar(
            percent: session.attendanceRate,
            color: open ? cs.secondary : TrustechColors.success,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${session.present} present · ${session.absent} absent',
                  style: TrustechTypography.caption.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              StatusChip(
                label: session.status,
                kind: open ? StatusKind.warning : StatusKind.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
