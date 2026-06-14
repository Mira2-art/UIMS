// Roles: REGISTRAR (ADMIN: view)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile_pro/src/features/academics/providers/academics_providers.dart';

class CourseCatalogDetailScreen extends ConsumerWidget {
  const CourseCatalogDetailScreen({super.key, required this.catalogId});

  final String catalogId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(catalogCourseDetailProvider(catalogId));
    final cs = Theme.of(context).colorScheme;

    if (course == null) {
      return const TrustechScaffold(
        title: 'Course Detail',
        body: Center(child: Text('Course not found')),
      );
    }

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Staff Portal'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card
            TrustechCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          course.programName.toUpperCase(),
                          style: TrustechTypography.overline.copyWith(color: cs.onPrimaryContainer),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Credits: ${course.units}',
                        style: TrustechTypography.label.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${course.code}: ${course.title}',
                    style: TrustechTypography.displayLarge.copyWith(color: cs.onSurface, fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description ?? 'Course description will appear here.',
                    style: TrustechTypography.bodyLarge.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  TrustechButton(
                    label: 'Edit Catalog Entry',
                    icon: Icons.edit_outlined,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Syllabus Summary
            _DetailSection(
              title: 'Syllabus Summary',
              icon: Icons.description_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.syllabus ?? 'Syllabus details will be published soon.',
                    style: TrustechTypography.bodyLarge,
                  ),
                  if (course.outcomes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...course.outcomes.map((o) => _OutcomeRow(label: o)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Timetable
            _DetailSection(
              title: 'Timetable & Venues',
              icon: Icons.event_note_outlined,
              child: course.timetable.isEmpty
                  ? const Text(
                      'No sessions scheduled yet.',
                      style: TrustechTypography.bodySmall,
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < course.timetable.length; i++) ...[
                          if (i > 0) const Divider(),
                          _TimetableRow(
                            day: course.timetable[i].day,
                            time: course.timetable[i].time,
                            venue: course.timetable[i].venue,
                            type: course.timetable[i].type,
                          ),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: 24),

            // Lecturer
            _DetailSection(
              title: 'Lecturer',
              child: Column(
                children: [
                  TrustechAvatar(name: course.lecturer, radius: 40),
                  const SizedBox(height: 12),
                  _LecturerName(name: course.lecturer),
                  if (course.lecturerTitle != null)
                    Text(
                      course.lecturerTitle!.toUpperCase(),
                      style: TrustechTypography.overline,
                    ),
                  const SizedBox(height: 12),
                  if (course.lecturerBio != null)
                    Text(
                      course.lecturerBio!,
                      textAlign: TextAlign.center,
                      style: TrustechTypography.bodySmall,
                    ),
                  const SizedBox(height: 16),
                  if (course.lecturerEmail != null)
                    _ActionLink(icon: Icons.mail_outline, label: course.lecturerEmail!),
                  const SizedBox(height: 8),
                  const _ActionLink(icon: Icons.visibility_outlined, label: 'View Profile'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Prerequisites
            _DetailSection(
              title: 'Prerequisites',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (course.prerequisites.isEmpty)
                    const Text('No prerequisites.', style: TrustechTypography.bodySmall)
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final p in course.prerequisites)
                          _PrereqChip(code: p.code, label: p.label),
                      ],
                    ),
                  const SizedBox(height: 16),
                  const _WarningBox(
                    message:
                        'Students without core prerequisites require departmental approval.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, this.icon, required this.child});
  final String title;
  final IconData? icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TrustechCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
                    const SizedBox(width: 8),
                  ],
                  Text(title, style: TrustechTypography.h2),
                ],
              ),
              Icon(Icons.edit_note, color: Theme.of(context).colorScheme.primary, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _OutcomeRow extends StatelessWidget {
  const _OutcomeRow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 8),
          Text(label, style: TrustechTypography.bodySmall),
        ],
      ),
    );
  }
}

class _TimetableRow extends StatelessWidget {
  const _TimetableRow({required this.day, required this.time, required this.venue, required this.type});
  final String day;
  final String time;
  final String venue;
  final String type;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day, style: TrustechTypography.label),
                Text(time, style: TrustechTypography.caption),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(venue, style: TrustechTypography.bodySmall),
                _Badge(label: type.toUpperCase(), color: type == 'Lecture' ? cs.secondary : cs.tertiary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionLink extends StatelessWidget {
  const _ActionLink({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: cs.primary, size: 18),
          const SizedBox(width: 8),
          Text(label, style: TrustechTypography.label.copyWith(color: cs.onSurface)),
        ],
      ),
    );
  }
}

class _LecturerName extends StatelessWidget {
  const _LecturerName({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: TrustechTypography.h2.copyWith(color: Theme.of(context).colorScheme.primary),
    );
  }
}

class _PrereqChip extends StatelessWidget {
  const _PrereqChip({required this.code, required this.label});
  final String code;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(code, style: TrustechTypography.label.copyWith(color: cs.primary)),
          const SizedBox(width: 4),
          Text(label, style: TrustechTypography.overline.copyWith(color: cs.onSurfaceVariant, fontSize: 9)),
        ],
      ),
    );
  }
}

class _WarningBox extends StatelessWidget {
  const _WarningBox({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: cs.error, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: TrustechTypography.bodySmall.copyWith(color: cs.error))),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TrustechTypography.overline.copyWith(color: color, fontSize: 8),
      ),
    );
  }
}
