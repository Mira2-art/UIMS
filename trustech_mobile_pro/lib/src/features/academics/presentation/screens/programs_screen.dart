// Roles: REGISTRAR (ADMIN: view)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile_pro/src/features/academics/providers/academics_providers.dart';
import 'package:trustech_mobile_pro/src/features/academics/data/mock/academics_mock.dart';

class ProgramsScreen extends ConsumerStatefulWidget {
  const ProgramsScreen({super.key});

  @override
  ConsumerState<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends ConsumerState<ProgramsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedDeptId;
  String _selectedDegreeType = 'Undergrad'; // 'Undergrad' or 'Graduate'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final departments = ref.watch(departmentsProvider);
    final allPrograms = ref.watch(filteredProgramsProvider(_selectedDeptId));
    final cs = Theme.of(context).colorScheme;

    final filteredPrograms = allPrograms.where((p) {
      final query = _searchQuery.toLowerCase();
      final matchesQuery = p.name.toLowerCase().contains(query) || p.code.toLowerCase().contains(query);
      final matchesDegree = _selectedDegreeType == 'Undergrad' 
          ? p.awardType.contains('B.') 
          : !p.awardType.contains('B.');
      return matchesQuery && matchesDegree;
    }).toList();

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Staff Portal'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ACADEMIC MANAGEMENT',
              style: TrustechTypography.overline.copyWith(color: cs.primary),
            ),
            const SizedBox(height: 4),
            Text(
              'Degree Programs',
              style: TrustechTypography.displayLarge.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 24),
            
            // Stats summary
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school_outlined, size: 20, color: cs.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    '${allPrograms.length} Active Programs',
                    style: TrustechTypography.label.copyWith(color: cs.onSurface),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Filters
            Text(
              'Search Programs',
              style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search by name or code...',
                prefixIcon: const Icon(Icons.search),
                fillColor: cs.surfaceContainerLow,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Department',
                        style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: _selectedDeptId,
                            isExpanded: true,
                            items: [
                              const DropdownMenuItem(value: null, child: Text('All Departments')),
                              ...departments.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))),
                            ],
                            onChanged: (val) => setState(() => _selectedDeptId = val),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Degree Type',
                        style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _DegreeTypeButton(
                              label: 'Undergrad',
                              isSelected: _selectedDegreeType == 'Undergrad',
                              onTap: () => setState(() => _selectedDegreeType = 'Undergrad'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _DegreeTypeButton(
                              label: 'Graduate',
                              isSelected: _selectedDegreeType == 'Graduate',
                              onTap: () => setState(() => _selectedDegreeType = 'Graduate'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Programs Grid/List
            if (filteredPrograms.isEmpty)
              const TrustechEmptyState(
                title: 'No Programs Found',
                message: 'Try adjusting your filters.',
                icon: Icons.history_edu_outlined,
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredPrograms.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _ProgramCard(program: filteredPrograms[index]);
                },
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Add Program'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.program});
  final Program program;

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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForProgram(program.code),
                  color: cs.primary,
                  size: 20,
                ),
              ),
              StatusChip(label: program.code, kind: StatusKind.warning),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            program.name,
            style: TrustechTypography.h2.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            'Core focus on algorithmic foundations, software engineering, and artificial intelligence systems.', // Mock description
            style: TrustechTypography.bodySmall.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DURATION',
                      style: TrustechTypography.overline.copyWith(color: cs.outline),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${program.duration} Years',
                          style: TrustechTypography.bodyLarge.copyWith(color: cs.onSurface),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CREDITS',
                      style: TrustechTypography.overline.copyWith(color: cs.outline),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.workspace_premium_outlined, size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${program.totalCredits} Units',
                          style: TrustechTypography.bodyLarge.copyWith(color: cs.onSurface),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconForProgram(String code) {
    if (code.contains('CS')) return Icons.terminal;
    if (code.contains('BIO')) return Icons.biotech;
    if (code.contains('BUS')) return Icons.attach_money;
    return Icons.history_edu;
  }
}

class _DegreeTypeButton extends StatelessWidget {
  const _DegreeTypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? cs.primary : cs.outlineVariant),
        ),
        child: Text(
          label,
          style: TrustechTypography.label.copyWith(
            color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
