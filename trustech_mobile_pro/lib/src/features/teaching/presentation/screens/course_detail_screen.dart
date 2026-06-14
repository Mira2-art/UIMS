// Roles: LECTURER
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/teaching/providers/teaching_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(teachingCourseProvider(courseId));
    final roster = ref.watch(courseRosterProvider(courseId));
    final cs = Theme.of(context).colorScheme;

    if (course == null) {
      return const Scaffold(
        appBar: AppHeaderBar.back(title: 'Course Detail'),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: TrustechEmptyState(
              title: 'Course unavailable',
              message:
                  'The selected course could not be found in the current semester.',
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Staff Portal',
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/courses/${course.id}/attendance'),
        child: const Icon(Icons.add_task_outlined),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AnnouncementBanner(
              message: 'New announcement: ${course.semester} exam schedule',
              actionLabel: 'View',
              onAction: () => context.push('/courses/${course.id}/announce'),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const StatusChip(
                  label: 'CORE MODULE',
                  kind: StatusKind.warning,
                ),
                const SizedBox(width: 8),
                Text(
                  course.semester,
                  style: TrustechTypography.bodySmall.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              course.code,
              style: TrustechTypography.displayLarge.copyWith(
                color: cs.onSurface,
              ),
            ),
            Text(
              course.title,
              style: TrustechTypography.h2.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const TrustechAvatar(name: 'Alex Rivers', radius: 18),
                const SizedBox(width: 10),
                Text(
                  'Lecturer: Alex Rivers',
                  style: TrustechTypography.bodyLarge.copyWith(
                    color: cs.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _BentoMetric(
                    icon: Icons.group,
                    label: 'ENROLLED STUDENTS',
                    value: course.studentCount.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BentoMetric(
                    icon: Icons.analytics,
                    label: 'AVG ATTENDANCE',
                    value: '${course.averageAttendance.round()}%',
                    accent: cs.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _CourseTabs(courseId: course.id),
            const SizedBox(height: 16),
            SectionHeader(
              title: 'Current Roster',
              actionLabel: 'Filter',
              onAction: () {},
            ),
            ...roster
                .take(3)
                .map(
                  (student) => InfoListCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    children: [
                      InfoListRow(
                        title: student.name,
                        subtitle:
                            'ID: ${student.matricNo} · ${student.program}',
                        leading: TrustechAvatar(name: student.name, radius: 20),
                        trailing: StatusChip(
                          label:
                              '${student.attendanceRate.round()}% ATTENDANCE',
                          kind: student.attendanceRate >= 85
                              ? StatusKind.success
                              : StatusKind.warning,
                        ),
                      ),
                    ],
                  ),
                ),
            const SizedBox(height: 8),
            TrustechButton(
              label: 'Add session task',
              icon: Icons.add,
              variant: TrustechButtonVariant.outline,
              onPressed: () => context.push('/courses/${course.id}/attendance'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BentoMetric extends StatelessWidget {
  const _BentoMetric({
    required this.icon,
    required this.label,
    required this.value,
    this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = accent ?? cs.primary;
    return TrustechCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 98,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TrustechTypography.displayLarge.copyWith(
                    color: cs.onSurface,
                    height: 1,
                  ),
                ),
                Text(
                  label,
                  style: TrustechTypography.overline.copyWith(
                    color: cs.outline,
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

class _CourseTabs extends StatelessWidget {
  const _CourseTabs({required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _TabLabel(label: 'Students', selected: true, onTap: () {}),
          _TabLabel(
            label: 'Materials',
            onTap: () => context.push('/courses/$courseId/materials'),
          ),
          _TabLabel(
            label: 'Timetable',
            onTap: () => context.push('/courses/$courseId/timetable'),
          ),
          _TabLabel(
            label: 'Exam Marks',
            onTap: () => context.push('/courses/$courseId/exam-marks'),
          ),
          _TabLabel(label: 'Syllabus', onTap: () {}),
        ],
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? cs.primary : cs.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
        ),
        child: Text(
          label,
          style: TrustechTypography.label.copyWith(
            color: selected ? cs.primary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
