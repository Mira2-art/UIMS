import 'package:flutter/material.dart';

import 'package:trustech_mobile/src/core/constants/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile/src/features/courses/data/mock/courses_mock.dart';
import 'package:trustech_mobile/src/features/courses/providers/courses_providers.dart';
import 'package:trustech_mobile/src/shared/ui_kit/ui_kit.dart';

class MyCoursesScreen extends ConsumerWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myCoursesProvider);

    return Scaffold(
      appBar: AppHeaderBar.home(
        title: 'My Courses',
        avatarName: 'John Doe',
        actions: [
          IconButton(
            tooltip: 'Register courses',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => context.push('/courses/register'),
          ),
        ],
        onNotification: () => context.push('/notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          _SemesterFilter(activeSemester: state.semester),
          const SizedBox(height: 18),
          if (state.isLoading)
            const Column(
              children: [
                SkeletonListTile(),
                SizedBox(height: 12),
                SkeletonListTile(),
              ],
            )
          else if (state.courses.isEmpty)
            TrustechEmptyState(
              title: 'No courses found',
              message:
                  'You have not registered any courses for this semester yet.',
              icon: Icons.school_outlined,
              actionLabel: 'Register Courses',
              onAction: () => context.push('/courses/register'),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Registered Courses',
                  actionLabel: 'Register',
                  onAction: () => context.push('/courses/register'),
                ),
                const SizedBox(height: 4),
                ...state.courses.map(
                  (course) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CourseCard(
                      course: course,
                      onTap: () => context.push('/courses/${course.id}'),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SemesterFilter extends StatelessWidget {
  const _SemesterFilter({required this.activeSemester});

  final String activeSemester;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const semesters = ['Fall 2024', 'Spring 2024', 'Winter 2023'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ACTIVE SEMESTER',
              style: TextStyle(
                fontFamily: TrustechTypography.fontFamily,
                color: cs.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(width: 7, height: 7),
                ),
                const SizedBox(width: 6),
                Text(
                  activeSemester,
                  style: TextStyle(
                    fontFamily: TrustechTypography.fontFamily,
                    color: cs.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: semesters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final semester = semesters[index];
              final active = semester == activeSemester;
              return ChoiceChip(
                label: Text(semester),
                selected: active,
                onSelected: (_) {},
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.onTap});

  final StudentCourse course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TrustechCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
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
                      course.code,
                      style: TextStyle(
                        fontFamily: TrustechTypography.fontFamily,
                        color: cs.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.9,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: TrustechTypography.fontFamily,
                        color: cs.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              StatusChip(label: course.status.label, kind: StatusKind.info),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.person_outline, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  course.lecturer,
                  style: TextStyle(
                    fontFamily: TrustechTypography.fontFamily,
                    color: cs.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.layers_outlined, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                '${course.units} Units',
                style: TextStyle(
                  fontFamily: TrustechTypography.fontFamily,
                  color: cs.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ProgressBar(percent: course.progress, color: cs.primary),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Course progress',
                style: TextStyle(
                  fontFamily: TrustechTypography.fontFamily,
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              Text(
                '${course.progress.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontFamily: TrustechTypography.fontFamily,
                  color: cs.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
