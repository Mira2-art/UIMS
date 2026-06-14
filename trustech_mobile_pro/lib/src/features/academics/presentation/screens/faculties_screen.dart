// Roles: REGISTRAR (ADMIN: view)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile_pro/src/features/academics/providers/academics_providers.dart';
import 'package:trustech_mobile_pro/src/features/academics/data/mock/academics_mock.dart';

class FacultiesScreen extends ConsumerStatefulWidget {
  const FacultiesScreen({super.key});

  @override
  ConsumerState<FacultiesScreen> createState() => _FacultiesScreenState();
}

class _FacultiesScreenState extends ConsumerState<FacultiesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final faculties = ref.watch(facultiesProvider);
    final cs = Theme.of(context).colorScheme;

    final filteredFaculties = faculties.where((f) {
      final query = _searchQuery.toLowerCase();
      return f.name.toLowerCase().contains(query) || f.code.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Staff Portal'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ADMINISTRATION',
                    style: TrustechTypography.overline.copyWith(color: cs.tertiary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Faculty Directory',
                    style: TrustechTypography.displayLarge.copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  TrustechTextField(
                    controller: _searchController,
                    hintText: 'Search by faculty name or code...',
                    prefixIcon: Icons.search,
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                  const SizedBox(height: 24),
                  // Faculty Grid
                  if (filteredFaculties.isEmpty)
                    const TrustechEmptyState(
                      title: 'No Faculties Found',
                      message: 'Try adjusting your search query.',
                      icon: Icons.school_outlined,
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1, // Bento-style usually adapts, but mobile-first is 1
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 2.2,
                      ),
                      itemCount: filteredFaculties.length,
                      itemBuilder: (context, index) {
                        return _FacultyCard(faculty: filteredFaculties[index]);
                      },
                    ),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomActionBar(count: filteredFaculties.length),
    );
  }
}

class _FacultyCard extends StatelessWidget {
  const _FacultyCard({required this.faculty});
  final Faculty faculty;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TrustechCard(
      padding: const EdgeInsets.all(16),
      onTap: () {
        // TODO: Navigation or Edit Sheet
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    faculty.code,
                    style: TrustechTypography.overline.copyWith(color: cs.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    faculty.name,
                    style: TrustechTypography.h3.copyWith(color: cs.onSurface),
                  ),
                ],
              ),
              StatusChip(
                label: faculty.status.label,
                kind: faculty.status == AcademicStatus.active ? StatusKind.success : StatusKind.neutral,
              ),
            ],
          ),
          const Spacer(),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person_outline, size: 20, color: cs.outline),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DEAN',
                    style: TrustechTypography.overline.copyWith(
                      fontSize: 9,
                      color: cs.outlineVariant,
                    ),
                  ),
                  Text(
                    faculty.dean,
                    style: TrustechTypography.bodySmall.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500,
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

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.8),
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Records',
                style: TrustechTypography.caption.copyWith(color: cs.outline),
              ),
              Text(
                '$count Faculties',
                style: TrustechTypography.h3.copyWith(color: cs.primary),
              ),
            ],
          ),
          const Spacer(),
          TrustechButton(
            label: 'Add Faculty',
            icon: Icons.add,
            onPressed: () {
              // TODO: Show Create Sheet
            },
          ),
        ],
      ),
    );
  }
}
