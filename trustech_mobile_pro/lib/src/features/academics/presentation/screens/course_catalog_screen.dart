// Roles: REGISTRAR (ADMIN: view)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile_pro/src/features/academics/providers/academics_providers.dart';
import 'package:trustech_mobile_pro/src/features/academics/data/mock/academics_mock.dart';

class CourseCatalogScreen extends ConsumerStatefulWidget {
  const CourseCatalogScreen({super.key});

  @override
  ConsumerState<CourseCatalogScreen> createState() => _CourseCatalogScreenState();
}

class _CourseCatalogScreenState extends ConsumerState<CourseCatalogScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(catalogCoursesProvider);
    final cs = Theme.of(context).colorScheme;

    final filtered = courses.where((c) {
      final q = _searchQuery.toLowerCase();
      return c.title.toLowerCase().contains(q) || c.code.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Staff Portal'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ACADEMIC ADMINISTRATION',
              style: TrustechTypography.overline.copyWith(color: cs.primary),
            ),
            const SizedBox(height: 4),
            Text(
              'Course Catalog',
              style: TrustechTypography.displayLarge.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage curriculum, track capacity, and review department assignments.',
              style: TrustechTypography.bodySmall.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            
            // Search & Filters
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by course code or title...',
                prefixIcon: const Icon(Icons.search),
                fillColor: cs.surface,
              ),
            ),
            const SizedBox(height: 24),

            // Header (Desktop feel on mobile)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(flex: 2, child: _HeaderText(label: 'CODE / UNITS')),
                  Expanded(flex: 4, child: _HeaderText(label: 'COURSE TITLE')),
                ],
              ),
            ),
            
            if (filtered.isEmpty)
              const TrustechEmptyState(
                title: 'No Courses Found',
                message: 'Adjust your search query.',
                icon: Icons.library_books_outlined,
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _CourseCard(course: filtered[index]);
                },
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Create Course'),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});
  final CatalogCourse course;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TrustechCard(
      onTap: () => context.push('/academics/catalog/${course.id}'),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.code,
                      style: TrustechTypography.h3.copyWith(color: cs.primary),
                    ),
                    Text(
                      '${course.units} Units',
                      style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: TrustechTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.terminal, size: 14, color: cs.outline),
                        const SizedBox(width: 4),
                        Text(
                          course.programName,
                          style: TrustechTypography.bodySmall.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatusBadge(status: course.status, available: course.availableSeats),
              const SizedBox(width: 8),
              _LecturerBadge(name: course.lecturer),
              const Spacer(),
              Icon(Icons.more_vert, size: 18, color: cs.outline),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TrustechTypography.overline.copyWith(color: Theme.of(context).colorScheme.outline),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.available});
  final CourseStatus status;
  final int available;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = status == CourseStatus.full ? cs.error : cs.secondary;
    final label = status == CourseStatus.full ? 'Full' : '$available Seats Left';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TrustechTypography.caption.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _LecturerBadge extends StatelessWidget {
  const _LecturerBadge({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        name,
        style: TrustechTypography.caption.copyWith(
          color: name == 'Unassigned' ? cs.error : cs.onSurfaceVariant,
          fontStyle: name == 'Unassigned' ? FontStyle.italic : null,
        ),
      ),
    );
  }
}
