// Roles: LECTURER
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/teaching/data/mock/teaching_mock.dart';
import 'package:trustech_mobile_pro/src/features/teaching/providers/teaching_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class MyCoursesScreen extends ConsumerWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(teachingCoursesProvider);

    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Staff Portal',
        actions: [
          IconButton(
            tooltip: 'Search courses',
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO(backend): wire course search when the API is available.
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const _SemesterFilters(),
            const SizedBox(height: 16),
            if (courses.isEmpty)
              const TrustechEmptyState(
                title: 'No courses assigned',
                message:
                    'Assigned courses will appear here after timetable publication.',
              )
            else
              ...courses.map(
                (course) => _CourseCard(
                  course: course,
                  onTap: () => context.push('/courses/${course.id}'),
                ),
              ),
            const SizedBox(height: 12),
            _AcademicCalendarPanel(
              onReview: () {
                if (courses.isNotEmpty) {
                  context.push('/courses/${courses.first.id}/gradebook');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SemesterFilters extends StatelessWidget {
  const _SemesterFilters();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(label: 'Fall 2024', selected: true),
          _FilterChip(label: 'Spring 2024'),
          _FilterChip(label: 'Summer 2024'),
          _FilterChip(label: 'Archives'),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.onTap});

  final TeachingCourse course;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FALL 2024',
                      style: TrustechTypography.overline.copyWith(
                        color: cs.tertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${course.code}: ${course.title}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TrustechTypography.h2.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${course.creditUnits}.0 Units',
                  style: TrustechTypography.caption.copyWith(
                    color: cs.onSecondaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _InlineMetric(
                icon: Icons.group_outlined,
                label: '${course.studentCount} Students',
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _InlineMetric(
                  icon: Icons.schedule_outlined,
                  label: course.nextClass,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ProgressBar(
            percent: course.gradeCompletion,
            height: 5,
            color: cs.primary,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Gradebook: ${course.gradeCompletion.round()}% Complete',
                  style: TrustechTypography.caption.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(
                course.gradeCompletion >= 100
                    ? Icons.check_circle_outline
                    : Icons.arrow_forward,
                color: cs.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineMetric extends StatelessWidget {
  const _InlineMetric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TrustechTypography.bodySmall.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _AcademicCalendarPanel extends StatelessWidget {
  const _AcademicCalendarPanel({required this.onReview});

  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_note_outlined, color: cs.onPrimary),
              const SizedBox(width: 8),
              Text(
                'Academic Calendar',
                style: TrustechTypography.h3.copyWith(color: cs.onPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Midterm submissions are due in 4 days. 12 pending grades require your attention.',
            style: TrustechTypography.bodySmall.copyWith(
              color: cs.onPrimary.withValues(alpha: 0.86),
            ),
          ),
          const SizedBox(height: 14),
          TrustechButton(
            label: 'Review Now',
            variant: TrustechButtonVariant.secondary,
            expand: false,
            height: 40,
            onPressed: onReview,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? cs.primaryContainer : cs.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected ? cs.primaryContainer : cs.outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: TrustechTypography.label.copyWith(
          color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
