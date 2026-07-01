// Roles: LECTURER
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/teaching/providers/teaching_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class AttendanceRecordsScreen extends ConsumerWidget {
  const AttendanceRecordsScreen({
    super.key,
    required this.courseId,
    required this.sessionId,
  });
  final String courseId;
  final String sessionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roster = ref.watch(courseRosterProvider(courseId));
    final session = ref.watch(
      attendanceSessionProvider((courseId: courseId, sessionId: sessionId)),
    );
    final cs = Theme.of(context).colorScheme;
    final avg = session?.attendanceRate ?? 0;
    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Attendance Records'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AnnouncementBanner(
              message: 'Attendance report ready for review.',
              actionLabel: 'View',
              onAction: () {},
            ),
            const SizedBox(height: 16),
            Text(
              'Attendance Records',
              style: TrustechTypography.displayLarge.copyWith(
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _Kpi(
                    label: 'STUDENTS',
                    value: roster.length.toString(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Kpi(
                    label: 'AVG. ATTENDANCE',
                    value: '${avg.round()}%',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Kpi(
                    label: 'AT RISK',
                    value: roster
                        .where((s) => s.attendanceRate < 75)
                        .length
                        .toString(),
                    error: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _FilterBox(
                    icon: Icons.calendar_today,
                    label: session?.date ?? 'Session Date',
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: _FilterBox(
                    icon: Icons.expand_more,
                    label: 'All Status',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...roster.map(
              (s) => InfoListCard(
                margin: const EdgeInsets.only(bottom: 8),
                children: [
                  InfoListRow(
                    title: s.name,
                    subtitle: s.matricNo,
                    leading: TrustechAvatar(name: s.name, radius: 18),
                    trailing: StatusChip(
                      label: '${s.attendanceRate.round()}%',
                      kind: s.attendanceRate < 75
                          ? StatusKind.error
                          : s.attendanceRate < 85
                          ? StatusKind.warning
                          : StatusKind.success,
                    ),
                  ),
                ],
              ),
            ),
            TrustechButton(
              label: 'View All ${roster.length} Students',
              variant: TrustechButtonVariant.text,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value, this.error = false});
  final String label;
  final String value;
  final bool error;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TrustechCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TrustechTypography.h1.copyWith(
              color: error ? cs.error : cs.primary,
            ),
          ),
          Text(
            label,
            style: TrustechTypography.overline.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBox extends StatelessWidget {
  const _FilterBox({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TrustechCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.outline),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TrustechTypography.caption.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
