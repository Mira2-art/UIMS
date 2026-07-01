import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile/src/core/auth/session_controller.dart';
import 'package:trustech_mobile/src/core/network/error_mapper.dart';
import 'package:trustech_mobile/src/features/grades/data/mock/grades_mock.dart';
import 'package:trustech_mobile/src/features/grades/providers/grades_providers.dart';
import 'package:trustech_mobile/src/shared/ui_kit/ui_kit.dart';

class TranscriptScreen extends ConsumerStatefulWidget {
  const TranscriptScreen({super.key});

  @override
  ConsumerState<TranscriptScreen> createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends ConsumerState<TranscriptScreen> {
  int _yearIndex = 0;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(transcriptProvider);
    final user = ref.watch(sessionProvider).user;

    return Scaffold(
      appBar: AppHeaderBar.home(
        title: 'Grades',
        avatarName: user?.fullName ?? 'Student',
        actions: [
          IconButton(
            tooltip: 'Academic standing',
            icon: const Icon(Icons.auto_graph_outlined),
            onPressed: () => context.push('/grades/standing'),
          ),
        ],
        onNotification: () => context.push('/notifications'),
      ),
      body: async.when(
        loading: () => const TrustechLoader(message: 'Loading your results…'),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: ErrorStateCard(
            message: friendlyError(e),
            onRetry: () => ref.invalidate(transcriptProvider),
          ),
        ),
        data: (t) {
          final years = t.years;
          if (years.isEmpty) {
            return const TrustechEmptyState(
              title: 'No results yet',
              message: 'Your grades appear here once published.',
              icon: Icons.workspace_premium_outlined,
            );
          }
          final yi = _yearIndex.clamp(0, years.length - 1);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
              _CgpaCard(cgpa: t.cgpa, finalizedTerms: t.finalizedTermCount),
              const SizedBox(height: 18),
              _YearSelector(
                years: years,
                selectedIndex: yi,
                onSelected: (i) => setState(() => _yearIndex = i),
              ),
              const SizedBox(height: 16),
              ...years[yi].terms.map(
                (term) => Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: _TermCard(term: term, year: years[yi].year),
                ),
              ),
              TrustechButton(
                label: 'Download PDF Report',
                icon: Icons.download_outlined,
                variant: TrustechButtonVariant.outline,
                onPressed: () {
                  // TODO(backend): generate official transcript PDF.
                  AppSnackbar.info(context, 'Transcript PDF export coming soon.');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CgpaCard extends StatelessWidget {
  const _CgpaCard({required this.cgpa, required this.finalizedTerms});

  final double? cgpa;
  final int finalizedTerms;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // CGPA is only meaningful from the 2nd completed semester.
    final showCgpa = cgpa != null && finalizedTerms >= 2;
    final standing = _standingLabel(cgpa);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'CUMULATIVE GPA',
                style: TextStyle(
                  color: cs.onPrimary.withValues(alpha: 0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              if (showCgpa)
                StatusChip.custom(label: standing, accent: cs.onPrimary),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                showCgpa ? cgpa!.toStringAsFixed(2) : '—',
                style: TextStyle(
                  color: cs.onPrimary,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '/ 4.00',
                  style: TextStyle(
                    color: cs.onPrimary.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            showCgpa
                ? 'Across $finalizedTerms published semesters.'
                : 'CGPA becomes available after your 2nd semester results.',
            style: TextStyle(
              color: cs.onPrimary.withValues(alpha: 0.85),
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _YearSelector extends StatelessWidget {
  const _YearSelector({
    required this.years,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<AcademicYearResult> years;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < years.length; i++) ...[
            InkWell(
              onTap: () => onSelected(i),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: i == selectedIndex
                      ? cs.primaryContainer
                      : cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: i == selectedIndex
                        ? cs.primary
                        : cs.outlineVariant,
                  ),
                ),
                child: Text(
                  years[i].year,
                  style: TextStyle(
                    color: i == selectedIndex
                        ? cs.onPrimaryContainer
                        : cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _TermCard extends StatelessWidget {
  const _TermCard({required this.term, required this.year});

  final TermResult term;
  final String year;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final gpa = term.gpa;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${term.label} · $year',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (gpa != null)
              StatusChip(
                label: 'GPA ${gpa.toStringAsFixed(2)}',
                kind: StatusKind.success,
              )
            else
              const StatusChip(
                label: 'Results pending',
                kind: StatusKind.warning,
              ),
          ],
        ),
        const SizedBox(height: 8),
        ...term.courses.map((c) => _CourseRow(course: c)),
      ],
    );
  }
}

class _CourseRow extends StatelessWidget {
  const _CourseRow({required this.course});

  final CourseResult course;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final finalized = course.isFinalized;

    return TrustechCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${course.code} · ${course.credits} CU',
                  style: TextStyle(
                    color: cs.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              if (finalized)
                StatusChip(
                  label: course.letter!,
                  kind: _letterKind(course.total!),
                )
              else
                const StatusChip(label: 'Exam pending', kind: StatusKind.neutral),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            course.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ScorePill(
                label: 'CA',
                value: course.caPublished
                    ? '${course.caScore.toStringAsFixed(0)}/30'
                    : '—',
                muted: !course.caPublished,
              ),
              const SizedBox(width: 8),
              _ScorePill(
                label: 'EXAM',
                value: course.examPublished
                    ? '${course.examScore.toStringAsFixed(0)}/70'
                    : 'Pending',
                muted: !course.examPublished,
              ),
              const SizedBox(width: 8),
              _ScorePill(
                label: 'TOTAL',
                value: finalized ? '${course.total!.toStringAsFixed(0)}/100' : '—',
                emphasize: finalized,
                muted: !finalized,
              ),
            ],
          ),
        ],
      ),
    );
  }

  StatusKind _letterKind(double total) {
    if (total >= 70) return StatusKind.success;
    if (total >= 50) return StatusKind.info;
    if (total >= 40) return StatusKind.warning;
    return StatusKind.error;
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.muted = false,
  });

  final String label;
  final String value;
  final bool emphasize;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final valueColor = muted
        ? cs.onSurfaceVariant
        : (emphasize ? cs.primary : cs.onSurface);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: emphasize
              ? cs.primary.withValues(alpha: 0.10)
              : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: emphasize ? cs.primary.withValues(alpha: 0.4) : cs.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _standingLabel(double? cgpa) {
  if (cgpa == null) return '—';
  if (cgpa >= 3.5) return "DEAN'S LIST";
  if (cgpa >= 2.0) return 'GOOD STANDING';
  return 'PROBATION';
}
