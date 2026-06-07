import 'package:flutter/material.dart';

import 'package:trustech_mobile/src/core/constants/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile/src/features/grades/data/mock/grades_mock.dart';
import 'package:trustech_mobile/src/features/grades/providers/grades_providers.dart';
import 'package:trustech_mobile/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile/src/shared/utils/theme_helper.dart';

class TranscriptScreen extends ConsumerWidget {
  const TranscriptScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transcript = ref.watch(transcriptProvider);

    return Scaffold(
      appBar: AppHeaderBar.home(
        title: 'Grades',
        avatarName: 'John Doe',
        actions: [
          IconButton(
            tooltip: 'Academic standing',
            icon: const Icon(Icons.auto_graph_outlined),
            onPressed: () => context.push('/grades/standing'),
          ),
        ],
        onNotification: () => context.push('/notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          _TranscriptHero(transcript: transcript),
          const SizedBox(height: 16),
          _TranscriptStats(transcript: transcript),
          const SizedBox(height: 20),
          SectionHeader(
            title: 'Course Transcript',
            actionLabel: 'Standing',
            onAction: () => context.push('/grades/standing'),
          ),
          const SizedBox(height: 4),
          ...transcript.semesters.map(
            (semester) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _SemesterGrades(semester: semester),
            ),
          ),
          TrustechButton(
            label: 'Download PDF Report',
            icon: Icons.download_outlined,
            variant: TrustechButtonVariant.outline,
            onPressed: () {
              // TODO(backend): generate and download official transcript PDF.
              AppSnackbar.info(context, 'Transcript PDF export coming soon.');
            },
          ),
        ],
      ),
    );
  }
}

class _TranscriptHero extends StatelessWidget {
  const _TranscriptHero({required this.transcript});

  final TranscriptSummary transcript;

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
            right: -32,
            top: -38,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const SizedBox(width: 124, height: 124),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'ACADEMIC STANDING',
                    style: TextStyle(
                      fontFamily: TrustechTypography.fontFamily,
                      color: cs.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  StatusChip(
                    label: transcript.status.label,
                    kind: _standingKind(transcript.status),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    transcript.currentGpa.toStringAsFixed(2),
                    style: TextStyle(
                      fontFamily: TrustechTypography.fontFamily,
                      color: cs.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      '/ 4.0 GPA',
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
              const SizedBox(height: 12),
              ProgressBar(percent: transcript.currentGpa / 4 * 100),
              const SizedBox(height: 10),
              Text(
                'You have earned ${transcript.creditsEarned} of ${transcript.creditsRequired} required credits.',
                style: TextStyle(
                  fontFamily: TrustechTypography.fontFamily,
                  color: cs.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TranscriptStats extends StatelessWidget {
  const _TranscriptStats({required this.transcript});

  final TranscriptSummary transcript;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.insights_outlined,
            label: 'CGPA',
            value: transcript.cgpa.toStringAsFixed(2),
            accent: cs.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: Icons.workspace_premium_outlined,
            label: 'Credits',
            value: '${transcript.creditsEarned}',
            accent: cs.primary,
          ),
        ),
      ],
    );
  }
}

class _SemesterGrades extends StatelessWidget {
  const _SemesterGrades({required this.semester});

  final TranscriptSemester semester;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: context.cBorder)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                semester.label.toUpperCase(),
                style: TextStyle(
                  fontFamily: TrustechTypography.fontFamily,
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Expanded(child: Divider(color: context.cBorder)),
          ],
        ),
        const SizedBox(height: 10),
        InfoListCard(
          children: [
            InfoListRow(
              title: 'Semester GPA',
              subtitle: '${semester.credits} credits completed',
              icon: Icons.auto_graph_outlined,
              trailingText: semester.gpa.toStringAsFixed(2),
            ),
            ...semester.courses.map(
              (grade) => InfoListRow(
                title: grade.title,
                subtitle:
                    '${grade.code} · ${grade.credits} Credits · ${grade.remark}',
                icon: Icons.school_outlined,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${grade.score.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontFamily: TrustechTypography.fontFamily,
                        color: cs.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(
                      label: grade.letterGrade,
                      kind: _gradeKind(grade.score),
                    ),
                  ],
                ),
                onTap: () => context.push('/courses/${grade.courseId}'),
              ),
            ),
          ],
        ),
      ],
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

StatusKind _gradeKind(double score) {
  if (score >= 80) return StatusKind.success;
  if (score >= 65) return StatusKind.info;
  if (score >= 50) return StatusKind.warning;
  return StatusKind.error;
}
