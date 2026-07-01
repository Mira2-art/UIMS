// Roles: LECTURER
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/teaching/data/mock/teaching_mock.dart';
import 'package:trustech_mobile_pro/src/features/teaching/providers/teaching_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class CourseMaterialsScreen extends ConsumerWidget {
  const CourseMaterialsScreen({super.key, required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(teachingCourseProvider(courseId));
    final materials = ref.watch(courseMaterialsProvider(courseId));
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Staff Portal',
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMaterialSheet(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              course?.code ?? 'Course',
              style: TrustechTypography.displayLarge.copyWith(
                color: cs.onSurface,
              ),
            ),
            Text(
              'Course Materials',
              style: TrustechTypography.h2.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            ...materials.map((material) => _MaterialRow(material: material)),
            const SizedBox(height: 16),
            Container(
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
                      Icon(Icons.auto_awesome, color: cs.onPrimary, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Learning Insights',
                        style: TrustechTypography.h2.copyWith(color: cs.onPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '85% of students viewed the Complexity video this week.',
                    style: TrustechTypography.bodySmall.copyWith(
                      color: cs.onPrimary.withValues(alpha: .86),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NEXT MILESTONE',
                    style: TrustechTypography.overline.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Midterm Examination',
                    style: TrustechTypography.h2.copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scheduled for March 15th. Materials are being finalized.',
                    style: TrustechTypography.bodySmall.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 72),
          ],
        ),
      ),
    );
  }

  void _showAddMaterialSheet(BuildContext context) {
    final titleController = TextEditingController();
    final linkController = TextEditingController();
    showAppSheet<void>(
      context,
      (sheetContext) => SheetScaffold(
        title: 'Add material',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TrustechTextField(
              controller: titleController,
              label: 'Title',
              hintText: 'e.g. Week 4 lecture notes',
              prefixIcon: Icons.title,
            ),
            const SizedBox(height: 12),
            TrustechTextField(
              controller: linkController,
              label: 'File or link',
              hintText: 'Upload integration comes later',
              prefixIcon: Icons.link_outlined,
            ),
            const SizedBox(height: 16),
            TrustechButton(
              label: 'Save draft',
              icon: Icons.save_outlined,
              onPressed: () {
                Navigator.of(sheetContext).pop();
              },
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      titleController.dispose();
      linkController.dispose();
    });
  }
}

class _MaterialRow extends StatelessWidget {
  const _MaterialRow({required this.material});
  final CourseMaterial material;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TrustechCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_iconFor(material.type), color: cs.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TrustechTypography.h3.copyWith(color: cs.onSurface),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    StatusChip(
                      label: material.isPublished ? 'Published' : 'Draft',
                      kind: material.isPublished
                          ? StatusKind.warning
                          : StatusKind.neutral,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Added ${material.publishedAt}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TrustechTypography.caption.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: cs.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String type) => switch (type) {
    'VIDEO' => Icons.movie_outlined,
    'ASSIGNMENT' => Icons.assignment_outlined,
    'LINK' => Icons.link_outlined,
    _ => Icons.description_outlined,
  };
}
