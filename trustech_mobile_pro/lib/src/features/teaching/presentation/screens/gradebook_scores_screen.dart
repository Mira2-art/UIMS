// Roles: LECTURER
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/teaching/data/mock/teaching_mock.dart';
import 'package:trustech_mobile_pro/src/features/teaching/providers/teaching_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class GradebookScoresScreen extends ConsumerWidget {
  const GradebookScoresScreen({
    super.key,
    required this.courseId,
    required this.assessmentId,
  });
  final String courseId;
  final String assessmentId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessment = ref.watch(
      gradebookAssessmentProvider((
        courseId: courseId,
        assessmentId: assessmentId,
      )),
    );
    final course = ref.watch(teachingCourseProvider(courseId));
    final roster = ref.watch(courseRosterProvider(courseId));
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppHeaderBar.back(
        title: assessment?.title ?? 'Scores',
        actions: [
          TrustechButton(
            label: 'Save',
            expand: false,
            height: 36,
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TrustechCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course?.title ?? 'Course',
                          style: TrustechTypography.h2.copyWith(
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          '${assessment?.type ?? 'Assessment'} · Max ${assessment?.maxScore.toStringAsFixed(0) ?? '100'}',
                          style: TrustechTypography.caption.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ProgressRing(
                    percent: assessment?.completionRate ?? 0,
                    size: 70,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const _ScoreHeader(),
            ...roster.asMap().entries.map(
              (e) => _ScoreRow(
                student: e.value,
                score: _scoreFor(e.key, assessment),
                maxScore: assessment?.maxScore ?? 100,
              ),
            ),
            const SizedBox(height: 12),
            TrustechCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Draft autosave is local mock data until backend grading endpoints are connected.',
                      style: TrustechTypography.caption.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Icon(Icons.info_outline, color: cs.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _scoreFor(int index, GradebookAssessment? assessment) {
    final max = assessment?.maxScore ?? 100;
    if (assessment == null || index >= assessment.enteredCount) return 0;
    return (max * (0.58 + (index % 5) * 0.08)).clamp(0, max).toDouble();
  }
}

class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'STUDENT',
              style: TrustechTypography.overline.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            width: 92,
            child: Text(
              'SCORE',
              textAlign: TextAlign.center,
              style: TrustechTypography.overline.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 76, child: Text('STATUS', textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.student,
    required this.score,
    required this.maxScore,
  });
  final CourseRosterStudent student;
  final double score;
  final double maxScore;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final entered = score > 0;
    return TrustechCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          TrustechAvatar(name: student.name, radius: 18),
          const SizedBox(width: 10),
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
                  student.matricNo,
                  style: TrustechTypography.caption.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 78,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.outline),
            ),
            child: Text(
              entered
                  ? '${score.toStringAsFixed(0)}/${maxScore.toStringAsFixed(0)}'
                  : '--',
              style: TrustechTypography.label.copyWith(color: cs.onSurface),
            ),
          ),
          const SizedBox(width: 8),
          StatusChip(
            label: entered ? 'Saved' : 'Pending',
            kind: entered ? StatusKind.success : StatusKind.neutral,
          ),
        ],
      ),
    );
  }
}
