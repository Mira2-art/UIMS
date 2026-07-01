// Roles: LECTURER
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/teaching/data/mock/teaching_mock.dart';
import 'package:trustech_mobile_pro/src/features/teaching/providers/teaching_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class GradesPublishScreen extends ConsumerWidget {
  const GradesPublishScreen({super.key, required this.courseId});
  final String courseId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessments = ref.watch(gradebookAssessmentsProvider(courseId));
    final course = ref.watch(teachingCourseProvider(courseId));
    final cs = Theme.of(context).colorScheme;
    final ready = assessments.where((a) => a.completionRate >= 100).length;
    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Grades Publish'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Grades Publish',
              style: TrustechTypography.h2.copyWith(color: cs.onSurface),
            ),
            Text(
              course?.title ?? 'Course',
              style: TrustechTypography.bodySmall.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.error.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.error.withValues(alpha: 0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: cs.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Publishing grades will notify all enrolled students via push and email.',
                      style: TrustechTypography.bodySmall.copyWith(color: cs.error),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TrustechButton(
              label: 'Publish selected grades',
              icon: Icons.send_outlined,
              onPressed: ready == 0
                  ? null
                  : () => _showPublishSheet(context, ready),
            ),
            const SizedBox(height: 20),
            Text(
              'PENDING RELEASE',
              style: TrustechTypography.overline.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ...assessments.map((a) => _PublishRow(assessment: a)),
            const SizedBox(height: 8),
            TrustechCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$ready assessment(s) ready for immediate release',
                      style: TrustechTypography.h3.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  Icon(Icons.lock_clock_outlined, color: cs.outline),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPublishSheet(BuildContext context, int readyCount) {
    showAppSheet<void>(
      context,
      (ctx) => SheetScaffold(
        title: 'Confirm publication',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InfoListCard(
              children: [
                InfoListRow(
                  title: '$readyCount assessment(s) ready',
                  subtitle: 'Students will receive notifications.',
                  icon: Icons.notifications_active_outlined,
                ),
                const InfoListRow(
                  title: 'Audit trail',
                  subtitle: 'Publication action will be recorded.',
                  icon: Icons.history_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TrustechButton(
              label: 'Confirm publish',
              icon: Icons.check_circle_outline,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublishRow extends StatelessWidget {
  const _PublishRow({required this.assessment});
  final GradebookAssessment assessment;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ready = assessment.completionRate >= 100;
    return TrustechCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assessment.title,
                  style: TrustechTypography.h3.copyWith(color: cs.onSurface),
                ),
                Text(
                  '${assessment.totalStudents} students · ${assessment.enteredCount} entered',
                  style: TrustechTypography.caption.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          StatusChip(
            label: assessment.isPublished
                ? 'Published'
                : ready
                ? 'Ready'
                : 'Locked',
            kind: assessment.isPublished || ready
                ? StatusKind.success
                : StatusKind.neutral,
          ),
          const SizedBox(width: 8),
          Switch(value: ready, onChanged: ready ? (_) {} : null),
        ],
      ),
    );
  }
}
