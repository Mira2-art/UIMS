// Roles: LECTURER
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/teaching/data/mock/teaching_mock.dart';
import 'package:trustech_mobile_pro/src/features/teaching/providers/teaching_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class CourseTimetableScreen extends ConsumerWidget {
  const CourseTimetableScreen({super.key, required this.courseId});
  final String courseId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(teachingCourseProvider(courseId));
    final entries = ref.watch(courseTimetableProvider(courseId));
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Staff Portal',
        actions: [
          TrustechButton(
            label: 'Add',
            icon: Icons.add_circle_outline,
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
            Text(
              course == null
                  ? 'Course Timetable'
                  : '${course.code}: ${course.title}',
              style: TrustechTypography.displayLarge.copyWith(
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 18),
            ...entries.map((entry) => _TimetableEntryCard(entry: entry)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TrustechCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Professor\'s Insight',
                          style: TrustechTypography.h2.copyWith(
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Two practical blocks are scheduled away from theory-heavy lectures.',
                          style: TrustechTypography.bodySmall.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.assignment_late_outlined,
                          color: cs.onSecondaryContainer,
                          size: 42,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '12 Pending Grades',
                          style: TrustechTypography.h3.copyWith(
                            color: cs.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimetableEntryCard extends StatelessWidget {
  const _TimetableEntryCard({required this.entry});
  final CourseTimetableEntry entry;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TrustechCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              entry.type == 'Practical'
                  ? Icons.school_outlined
                  : Icons.terminal_outlined,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.day,
                  style: TrustechTypography.h3.copyWith(color: cs.onSurface),
                ),
                Text(
                  '${entry.time} · ${entry.venue}',
                  style: TrustechTypography.caption.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                Text(
                  entry.note,
                  style: TrustechTypography.caption.copyWith(color: cs.outline),
                ),
              ],
            ),
          ),
          TrustechButton(
            label: 'Manage',
            expand: false,
            height: 40,
            variant: TrustechButtonVariant.outline,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
