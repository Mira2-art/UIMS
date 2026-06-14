// Roles: REGISTRAR (ADMIN: view)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile_pro/src/features/academics/providers/academics_providers.dart';
import 'package:trustech_mobile_pro/src/features/academics/data/mock/academics_mock.dart';

class DepartmentsScreen extends ConsumerStatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  ConsumerState<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends ConsumerState<DepartmentsScreen> {
  String? _selectedFacultyId;

  @override
  Widget build(BuildContext context) {
    final faculties = ref.watch(facultiesProvider);
    final departments = ref.watch(filteredDepartmentsProvider(_selectedFacultyId));
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Staff Portal'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Academic Departments',
              style: TrustechTypography.displayLarge.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage and view departmental hierarchies across faculties.',
              style: TrustechTypography.bodyLarge.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            // Filter and Action
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FACULTY FILTER',
                        style: TrustechTypography.overline.copyWith(color: cs.outline),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: _selectedFacultyId,
                            isExpanded: true,
                            items: [
                              const DropdownMenuItem(value: null, child: Text('All Faculties')),
                              ...faculties.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))),
                            ],
                            onChanged: (val) => setState(() => _selectedFacultyId = val),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: TrustechButton(
                    label: 'Add',
                    icon: Icons.add,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Department List
            if (departments.isEmpty)
              const TrustechEmptyState(
                title: 'No Departments Found',
                message: 'Try selecting a different faculty.',
                icon: Icons.account_tree_outlined,
              )
            else ...[
              // Highlight the first one for "Bento" feel on mobile
              _DepartmentHighlightCard(dept: departments.first),
              const SizedBox(height: 16),
              ...departments.skip(1).map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _DepartmentCard(dept: d),
                  )),
            ],
            // Summary Card
            _OverviewStatCard(
              count: departments.length,
              total: 12, // Mock total
              facultyName: _selectedFacultyId != null
                  ? faculties.firstWhere((f) => f.id == _selectedFacultyId).name
                  : 'the University',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _DepartmentHighlightCard extends StatelessWidget {
  const _DepartmentHighlightCard({required this.dept});
  final Department dept;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TrustechCard(
      padding: EdgeInsets.zero,
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=800&q=80'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      dept.code,
                      style: TrustechTypography.overline.copyWith(color: cs.onPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        dept.name,
                        style: TrustechTypography.h2.copyWith(color: cs.onSurface),
                      ),
                    ),
                    const StatusChip(label: 'GROWTH', kind: StatusKind.warning),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: cs.surfaceContainerHigh,
                      child: Icon(Icons.person, size: 18, color: cs.primary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HEAD OF DEPARTMENT',
                          style: TrustechTypography.overline.copyWith(fontSize: 9, color: cs.outline),
                        ),
                        Text(
                          dept.hod,
                          style: TrustechTypography.label.copyWith(color: cs.onSurface),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward, size: 20, color: cs.onSurfaceVariant),
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

class _DepartmentCard extends StatelessWidget {
  const _DepartmentCard({required this.dept});
  final Department dept;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TrustechCard(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  dept.code,
                  style: TrustechTypography.overline.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
              Icon(Icons.more_vert, size: 20, color: cs.outline),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dept.name,
            style: TrustechTypography.h3.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.shield, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                dept.hod,
                style: TrustechTypography.label.copyWith(color: cs.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '28 FACULTY',
                style: TrustechTypography.overline.copyWith(color: cs.outline),
              ),
              Text(
                'ACTIVE',
                style: TrustechTypography.overline.copyWith(color: cs.secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewStatCard extends StatelessWidget {
  const _OverviewStatCard({
    required this.count,
    required this.total,
    required this.facultyName,
  });
  final int count;
  final int total;
  final String facultyName;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.account_tree_outlined, size: 48, color: cs.onPrimary),
          const SizedBox(height: 16),
          Text(
            'Faculty Overview',
            style: TrustechTypography.h2.copyWith(color: cs.onPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'You are currently viewing $count out of $total departments in $facultyName.',
            textAlign: TextAlign.center,
            style: TrustechTypography.bodyMedium.copyWith(color: cs.onPrimary.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 20),
          TrustechButton(
            label: 'View Detailed Report',
            variant: TrustechButtonVariant.secondary,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
