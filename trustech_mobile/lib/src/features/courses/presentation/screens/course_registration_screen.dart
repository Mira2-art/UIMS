import 'package:flutter/material.dart';

import 'package:trustech_mobile/src/core/constants/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile/src/features/courses/data/mock/courses_mock.dart';
import 'package:trustech_mobile/src/features/courses/providers/courses_providers.dart';
import 'package:trustech_mobile/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile/src/shared/utils/theme_helper.dart';

class CourseRegistrationScreen extends ConsumerStatefulWidget {
  const CourseRegistrationScreen({super.key});

  @override
  ConsumerState<CourseRegistrationScreen> createState() =>
      _CourseRegistrationScreenState();
}

class _CourseRegistrationScreenState
    extends ConsumerState<CourseRegistrationScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final window = ref.watch(registrationWindowProvider);
    final courses = ref.watch(availableCoursesProvider);

    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Course Registration',
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          _RegistrationBanner(window: window),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: TrustechTextField(
                  controller: _searchController,
                  hintText: 'Search courses...',
                  prefixIcon: Icons.search,
                ),
              ),
              const SizedBox(width: 10),
              _FilterButton(
                onTap: () => AppSnackbar.info(context, 'Filters coming soon.'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _CategoryScroller(),
          const SizedBox(height: 20),
          SectionHeader(
            title: window.isOpen ? 'Available Courses' : 'Preview Courses',
          ),
          const SizedBox(height: 4),
          ...courses.map(
            (course) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AvailableCourseCard(
                course: course,
                registrationOpen: window.isOpen,
                onTap: () => context.push('/courses/${course.id}'),
                onEnroll: () => _showEnrollSheet(context, course),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEnrollSheet(BuildContext context, AvailableCourse course) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: false,
      builder: (sheetContext) {
        return SheetScaffold(
          title: 'Confirm Enrollment',
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
                'This is a mock UI action. Backend registration will validate capacity, prerequisites and fee holds before enrollment.',
                style: TextStyle(
                  fontFamily: TrustechTypography.fontFamily,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              TrustechButton(
                label: 'Enroll in Course',
                icon: Icons.check_circle_outline,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  AppSnackbar.success(
                    context,
                    '${course.code} enrollment selected.',
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

class _RegistrationBanner extends StatelessWidget {
  const _RegistrationBanner({required this.window});

  final RegistrationWindow window;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = window.isOpen ? cs.primary : cs.secondary;
    final icon = window.isOpen
        ? Icons.radio_button_checked
        : Icons.lock_clock_outlined;
    final title = window.isOpen
        ? window.semester
        : 'Registration is currently closed';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cBorder),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -32,
            bottom: -34,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const SizedBox(width: 116, height: 116),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: accent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    window.isOpen
                        ? window.phase.toUpperCase()
                        : 'STATUS: CLOSED',
                    style: TextStyle(
                      fontFamily: TrustechTypography.fontFamily,
                      color: accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  StatusChip(
                    label: window.isOpen ? 'Open Now' : 'Closed',
                    kind: window.isOpen
                        ? StatusKind.success
                        : StatusKind.warning,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontFamily: TrustechTypography.fontFamily,
                  color: cs.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                window.message,
                style: TextStyle(
                  fontFamily: TrustechTypography.fontFamily,
                  color: cs.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(width: 7, height: 7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      window.secondaryMessage,
                      style: TextStyle(
                        fontFamily: TrustechTypography.fontFamily,
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 52,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
        child: Icon(Icons.tune, color: cs.onSurfaceVariant),
      ),
    );
  }
}

class _CategoryScroller extends StatelessWidget {
  const _CategoryScroller();

  final List<String> _categories = const [
    'All',
    'Computer Science',
    'Mathematics',
    'Engineering',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ChoiceChip(
            label: Text(_categories[index]),
            selected: index == 0,
            onSelected: (_) {},
          );
        },
      ),
    );
  }
}

class _AvailableCourseCard extends StatelessWidget {
  const _AvailableCourseCard({
    required this.course,
    required this.registrationOpen,
    required this.onTap,
    required this.onEnroll,
  });

  final AvailableCourse course;
  final bool registrationOpen;
  final VoidCallback onTap;
  final VoidCallback onEnroll;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Opacity(
      opacity: registrationOpen ? 1 : 0.72,
      child: TrustechCard(
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
                      StatusChip.custom(label: course.code, accent: cs.primary),
                      const SizedBox(height: 8),
                      Text(
                        course.title,
                        style: TextStyle(
                          fontFamily: TrustechTypography.fontFamily,
                          color: cs.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${course.units}\nUnits',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: TrustechTypography.fontFamily,
                      color: cs.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 18,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
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
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Capacity',
                  style: TextStyle(
                    fontFamily: TrustechTypography.fontFamily,
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${course.capacityUsed}/${course.capacityTotal}',
                  style: TextStyle(
                    fontFamily: TrustechTypography.fontFamily,
                    color: cs.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ProgressBar(percent: course.capacityPercent, color: cs.primary),
            const SizedBox(height: 12),
            StatusChip(
              label: 'Prereq: ${course.prerequisite}',
              kind: StatusKind.neutral,
            ),
            const SizedBox(height: 14),
            TrustechButton(
              label: registrationOpen ? 'Enroll' : 'Registration Closed',
              icon: registrationOpen
                  ? Icons.add_circle_outline
                  : Icons.lock_outline,
              onPressed: registrationOpen ? onEnroll : null,
              variant: registrationOpen
                  ? TrustechButtonVariant.primary
                  : TrustechButtonVariant.outline,
            ),
          ],
        ),
      ),
    );
  }
}
