// Roles: LECTURER
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/teaching/data/mock/teaching_mock.dart';
import 'package:trustech_mobile_pro/src/features/teaching/providers/teaching_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class GradebookAssessmentsScreen extends ConsumerWidget {
  const GradebookAssessmentsScreen({super.key, required this.courseId});
  final String courseId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(teachingCourseProvider(courseId));
    final assessments = ref.watch(gradebookAssessmentsProvider(courseId));
    final cs = Theme.of(context).colorScheme;
    final caItems = assessments.where((a) => !a.isExam).toList();
    final examItems = assessments.where((a) => a.isExam).toList();
    final exam = examItems.isEmpty ? null : examItems.first;
    final caWeight = caItems.fold<double>(0, (s, a) => s + a.weightPercent);

    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Gradebook',
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Courses > ${course?.code ?? 'Course'}',
              style: TrustechTypography.caption.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Gradebook Assessments',
              style: TrustechTypography.displayLarge.copyWith(
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Final grade = CA (30) + Exam (70) → 100',
              style: TrustechTypography.bodySmall.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.fact_check_outlined,
                    label: 'CA Weight',
                    value: '${caWeight.round()}/30',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.lock_outline,
                    label: 'Exam (Dean)',
                    value: '${exam?.weightPercent.round() ?? 70}/70',
                    accent: cs.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const SectionHeader(title: 'Continuous Assessment'),
            const SizedBox(height: 4),
            ...caItems.map(
              (a) => _AssessmentCard(
                assessment: a,
                onTap: () =>
                    context.push('/courses/$courseId/gradebook/${a.id}'),
              ),
            ),
            TrustechCard(
              child: Column(
                children: [
                  Icon(Icons.assignment_add, size: 44, color: cs.outline),
                  const SizedBox(height: 8),
                  Text(
                    'Add CA assessment',
                    style: TrustechTypography.h3.copyWith(color: cs.onSurface),
                  ),
                  Text(
                    'Continuous assessment weights must sum to 30.',
                    textAlign: TextAlign.center,
                    style: TrustechTypography.caption.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Final Examination'),
            const SizedBox(height: 4),
            if (exam != null)
              _ExamCard(
                exam: exam,
                onView: () => context.push('/courses/$courseId/exam-marks'),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.exam, required this.onView});
  final GradebookAssessment exam;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TrustechCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  exam.title,
                  style: TrustechTypography.h2.copyWith(color: cs.onSurface),
                ),
              ),
              const StatusChip(label: 'EXAM · /70', kind: StatusKind.info),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Entered by the Faculty Dean / School Secretariat — read-only for lecturers.',
            style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCol(
                  label: 'WEIGHT',
                  value: '${exam.weightPercent.toStringAsFixed(0)}%',
                ),
              ),
              _MetricCol(
                label: 'MAX SCORE',
                value: exam.maxScore.toStringAsFixed(0),
                alignEnd: true,
              ),
            ],
          ),
          const SizedBox(height: 14),
          TrustechButton(
            label: 'View exam marks',
            icon: Icons.visibility_outlined,
            variant: TrustechButtonVariant.outline,
            onPressed: onView,
          ),
        ],
      ),
    );
  }
}

class _MetricCol extends StatelessWidget {
  const _MetricCol({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });
  final String label;
  final String value;
  final bool alignEnd;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TrustechTypography.overline.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TrustechTypography.h3.copyWith(
            color: alignEnd ? cs.onSurface : cs.primary,
          ),
        ),
      ],
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({required this.assessment, required this.onTap});
  final GradebookAssessment assessment;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TrustechCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (assessment.isPublished)
                const StatusChip(label: 'PUBLISHED', kind: StatusKind.warning),
              const Spacer(),
              Icon(Icons.edit, color: cs.primary, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            assessment.title,
            style: TrustechTypography.h2.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCol(
                  label: 'WEIGHT',
                  value: '${assessment.weightPercent.toStringAsFixed(0)}%',
                ),
              ),
              _MetricCol(
                label: 'MAX SCORE',
                value: assessment.maxScore.toStringAsFixed(0),
                alignEnd: true,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${assessment.enteredCount}/${assessment.totalStudents} scores entered',
            style: TrustechTypography.caption.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
