// Roles: ADMIN (ADMIN: manage)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile_pro/src/features/admin/providers/admin_providers.dart';
import 'package:trustech_mobile_pro/src/features/admin/data/mock/admin_mock.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _roleFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider);
    final cs = Theme.of(context).colorScheme;

    final filtered = users.where((u) {
      final q = _searchQuery.toLowerCase();
      final matchesQuery = u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q);
      final matchesRole = _roleFilter == null || u.role == _roleFilter;
      return matchesQuery && matchesRole;
    }).toList();
    final roles = users.map((u) => u.role).toSet().toList();

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'User Management'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search & Filter
            TrustechTextField(
              controller: _searchController,
              hintText: 'Search by Name or Email...',
              prefixIcon: Icons.search,
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All Roles',
                    isSelected: _roleFilter == null,
                    onTap: () => setState(() => _roleFilter = null),
                  ),
                  const SizedBox(width: 8),
                  ...roles.map((r) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: r,
                          isSelected: _roleFilter == r,
                          onTap: () => setState(() => _roleFilter = r),
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            if (filtered.isEmpty)
              const TrustechEmptyState(
                title: 'No Users Found',
                message: 'Adjust your search or filter.',
                icon: Icons.person_off_outlined,
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _UserRow(user: filtered[index]);
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
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Add User'),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TrustechCard(
      onTap: () => context.push('/admin/users/${user.id}'),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          TrustechAvatar(name: user.name, radius: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: TrustechTypography.label.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface)),
                Text(user.role, style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          StatusChip(
            label: user.status.label,
            kind: user.status == UserStatus.active ? StatusKind.success : StatusKind.error,
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, size: 18, color: cs.outline),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: cs.outlineVariant),
        ),
        child: Text(
          label,
          style: TrustechTypography.label.copyWith(
            color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
