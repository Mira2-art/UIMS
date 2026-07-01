import 'package:flutter/material.dart';

import 'package:trustech_mobile/src/core/constants/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile/src/features/courses/data/mock/courses_mock.dart';
import 'package:trustech_mobile/src/features/courses/providers/courses_providers.dart';
import 'package:trustech_mobile/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile/src/shared/utils/theme_helper.dart';

class CourseMaterialsScreen extends ConsumerWidget {
  const CourseMaterialsScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(courseDetailProvider(courseId)).valueOrNull;
    final materials = ref.watch(courseMaterialsProvider(courseId)).valueOrNull ?? const [];
    final groupedMaterials = _groupBySection(materials);

    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Course Materials',
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
          _MaterialsSummary(course: course, materials: materials),
          const SizedBox(height: 20),
          if (materials.isEmpty)
            TrustechEmptyState(
              title: 'No materials uploaded',
              message:
                  'Your lecturer has not published resources for this course yet.',
              icon: Icons.folder_open_outlined,
              actionLabel: 'Back to Course',
              onAction: () => context.pop(),
            )
          else
            ...groupedMaterials.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: _MaterialSection(
                  title: entry.key,
                  materials: entry.value,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MaterialsSummary extends StatelessWidget {
  const _MaterialsSummary({required this.course, required this.materials});

  final CourseDetail? course;
  final List<CourseMaterial> materials;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final newCount = materials.where((material) => material.isNew).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.cBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.folder_copy_outlined, color: cs.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course == null ? 'Course Materials' : course!.code,
                  style: TextStyle(
                    fontFamily: TrustechTypography.fontFamily,
                    color: cs.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  course?.title ?? 'Materials Library',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: TrustechTypography.fontFamily,
                    color: cs.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusChip(
                      label: '${materials.length} files',
                      kind: StatusKind.info,
                    ),
                    if (newCount > 0)
                      StatusChip(
                        label: '$newCount new',
                        kind: StatusKind.success,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialSection extends StatelessWidget {
  const _MaterialSection({required this.title, required this.materials});

  final String title;
  final List<CourseMaterial> materials;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: 4),
        InfoListCard(
          children: materials
              .map((material) => _MaterialRow(material: material))
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _MaterialRow extends StatelessWidget {
  const _MaterialRow({required this.material});

  final CourseMaterial material;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InfoListRow(
      title: material.title,
      subtitle:
          '${material.type.label} · ${material.sizeLabel} · ${material.updatedLabel}',
      icon: _materialIcon(material.type),
      iconAccent: _materialAccent(context, material.type),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (material.isNew) ...[
            const StatusChip(label: 'New', kind: StatusKind.info),
            const SizedBox(width: 8),
          ],
          IconButton(
            tooltip: 'Download material',
            icon: Icon(Icons.download_outlined, color: cs.primary),
            onPressed: () {
              // TODO(backend): request signed download URL for material.id.
              AppSnackbar.info(context, '${material.title} download queued.');
            },
          ),
        ],
      ),
      onTap: () {
        // TODO(backend): open material preview or external URL based on type.
        AppSnackbar.info(context, '${material.title} preview coming soon.');
      },
    );
  }
}

Map<String, List<CourseMaterial>> _groupBySection(List<CourseMaterial> items) {
  final grouped = <String, List<CourseMaterial>>{};
  for (final item in items) {
    grouped.putIfAbsent(item.group, () => <CourseMaterial>[]).add(item);
  }
  return grouped;
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

Color _materialAccent(BuildContext context, CourseMaterialType type) {
  final cs = Theme.of(context).colorScheme;
  switch (type) {
    case CourseMaterialType.assignment:
      return cs.secondary;
    case CourseMaterialType.video:
      return cs.tertiary;
    case CourseMaterialType.document:
    case CourseMaterialType.link:
    case CourseMaterialType.syllabus:
      return cs.primary;
  }
}
