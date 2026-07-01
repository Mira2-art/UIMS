import 'package:flutter/material.dart';

import 'package:trustech_mobile/src/core/constants/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile/src/features/courses/data/mock/courses_mock.dart';
import 'package:trustech_mobile/src/features/courses/providers/courses_providers.dart';
import 'package:trustech_mobile/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile/src/shared/utils/theme_helper.dart';

class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(courseDetailProvider(courseId)).valueOrNull;

    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Course Detail',
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: course == null
          ? TrustechEmptyState(
              title: 'Course not found',
              message: 'This mock course could not be matched to your records.',
              icon: Icons.school_outlined,
              actionLabel: 'Back to Courses',
              onAction: () => context.go('/courses'),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: [
                _CourseHero(course: course),
                const SizedBox(height: 16),
                _CourseStats(course: course),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Course Actions'),
                const SizedBox(height: 4),
                InfoListCard(
                  children: [
                    InfoListRow(
                      title: 'Materials',
                      subtitle: '${course.materialCount} resources available',
                      icon: Icons.folder_copy_outlined,
                      trailingText: 'Open',
                      showChevron: true,
                      onTap: () => context.push('/courses/$courseId/materials'),
                    ),
                    InfoListRow(
                      title: 'Attendance',
                      subtitle:
                          '${course.attendancePercent.toStringAsFixed(0)}% recorded attendance',
                      icon: Icons.fact_check_outlined,
                      iconAccent: Theme.of(context).colorScheme.secondary,
                      trailing: StatusChip(
                        label: course.attendancePercent >= 75
                            ? 'Safe'
                            : 'At Risk',
                        kind: course.attendancePercent >= 75
                            ? StatusKind.success
                            : StatusKind.warning,
                      ),
                      onTap: () =>
                          context.push('/courses/$courseId/attendance'),
                    ),
                    InfoListRow(
                      title: 'Weekly Timetable',
                      subtitle: course.scheduleSummary,
                      icon: Icons.calendar_month_outlined,
                      showChevron: true,
                      onTap: () => context.push('/home/timetable'),
                    ),
                    InfoListRow(
                      title: 'Grades',
                      subtitle: 'Current standing: ${course.currentGrade}',
                      icon: Icons.workspace_premium_outlined,
                      trailingText: 'View',
                      onTap: () => context.go('/grades'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SectionHeader(
                  title: 'Recent Materials',
                  actionLabel: 'See All',
                  onAction: () => context.push('/courses/$courseId/materials'),
                ),
                const SizedBox(height: 4),
                InfoListCard(
                  children: course.recentMaterials
                      .map(
                        (material) => InfoListRow(
                          title: material.title,
                          subtitle:
                              '${material.type.label} · ${material.sizeLabel}',
                          icon: _materialIcon(material.type),
                          trailing: material.isNew
                              ? const StatusChip(
                                  label: 'New',
                                  kind: StatusKind.info,
                                )
                              : null,
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: 20),
                TrustechButton(
                  label: 'Drop Course Request',
                  icon: Icons.remove_circle_outline,
                  variant: TrustechButtonVariant.outline,
                  onPressed: () => _showDropCourseSheet(context, course),
                ),
              ],
            ),
    );
  }

  void _showDropCourseSheet(BuildContext context, CourseDetail course) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: false,
      builder: (sheetContext) {
        return SheetScaffold(
          title: 'Drop Course Request',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              InfoListCard(
                children: [
                  InfoListRow(
                    title: '${course.code} · ${course.title}',
                    subtitle: '${course.lecturer} · ${course.units} Units',
                    icon: Icons.school_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'This is a mock UI action. Backend submission will validate add/drop windows, fee holds and advisor approval rules.',
                style: TextStyle(
                  fontFamily: TrustechTypography.fontFamily,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              TrustechButton(
                label: 'Submit Drop Request',
                icon: Icons.send_outlined,
                variant: TrustechButtonVariant.destructive,
                onPressed: () {
                  // TODO(backend): submit course drop request to /courses/{id}/drop-requests.
                  Navigator.of(sheetContext).pop();
                  AppSnackbar.warning(
                    context,
                    '${course.code} drop request prepared.',
                  );
                },
              ),
              const SizedBox(height: 10),
              TrustechButton(
                label: 'Cancel',
                variant: TrustechButtonVariant.text,
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CourseHero extends StatelessWidget {
  const _CourseHero({required this.course});

  final CourseDetail course;

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
            right: -38,
            top: -42,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const SizedBox(width: 132, height: 132),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StatusChip.custom(label: course.code, accent: cs.primary),
                  const SizedBox(width: 8),
                  StatusChip(label: course.semester, kind: StatusKind.neutral),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                course.title,
                style: TextStyle(
                  fontFamily: TrustechTypography.fontFamily,
                  color: cs.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                course.description,
                style: TextStyle(
                  fontFamily: TrustechTypography.fontFamily,
                  color: cs.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _MetaPill(icon: Icons.person_outline, label: course.lecturer),
                  _MetaPill(
                    icon: Icons.account_tree_outlined,
                    label: course.department,
                  ),
                  _MetaPill(
                    icon: Icons.layers_outlined,
                    label: '${course.units} Units',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CourseStats extends StatelessWidget {
  const _CourseStats({required this.course});

  final CourseDetail course;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.fact_check_outlined,
                label: 'Attendance',
                value: '${course.attendancePercent.toStringAsFixed(0)}%',
                accent: course.attendancePercent >= 75
                    ? cs.primary
                    : cs.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.grade_outlined,
                label: 'Current Grade',
                value: course.currentGrade,
                accent: cs.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.schedule_outlined,
                label: 'Next Class',
                value: course.nextClass,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.people_outline,
                label: 'Enrolled',
                value: '${course.enrollmentCount}/${course.capacity}',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: TrustechTypography.fontFamily,
              color: cs.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _materialIcon(CourseMaterialType type) {
  switch (type) {
    case CourseMaterialType.document:
      return Icons.description_outlined;
    case CourseMaterialType.video:
      return Icons.play_circle_outline;
    case CourseMaterialType.assignment:
      return Icons.assignment_outlined;
    case CourseMaterialType.link:
      return Icons.link;
    case CourseMaterialType.syllabus:
      return Icons.menu_book_outlined;
  }
}
