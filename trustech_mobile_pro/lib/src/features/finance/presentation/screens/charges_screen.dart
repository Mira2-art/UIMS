// Roles: BURSAR (FINANCE: manage)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile_pro/src/features/finance/providers/finance_providers.dart';
import 'package:trustech_mobile_pro/src/features/finance/data/mock/finance_mock.dart';

class ChargesScreen extends ConsumerStatefulWidget {
  const ChargesScreen({super.key});

  @override
  ConsumerState<ChargesScreen> createState() => _ChargesScreenState();
}

class _ChargesScreenState extends ConsumerState<ChargesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  ChargeStatus? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final charges = ref.watch(chargesProvider);
    final cs = Theme.of(context).colorScheme;

    final filtered = charges.where((c) {
      final q = _searchQuery.toLowerCase();
      final matchesQuery = c.studentName.toLowerCase().contains(q) || c.studentId.toLowerCase().contains(q);
      final matchesStatus = _statusFilter == null || c.status == _statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Finance Portal'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search & Filter
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by Student Name or ID...',
                prefixIcon: const Icon(Icons.search),
                fillColor: cs.surfaceContainerLow,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All Charges',
                    isSelected: _statusFilter == null,
                    onTap: () => setState(() => _statusFilter = null),
                  ),
                  const SizedBox(width: 8),
                  ...ChargeStatus.values.map((s) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: s.label,
                          isSelected: _statusFilter == s,
                          onTap: () => setState(() => _statusFilter = s),
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Table Header (Stacked for mobile but with semantic feel)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(flex: 4, child: _HeaderText(label: 'STUDENT DETAILS')),
                  Expanded(flex: 3, child: _HeaderText(label: 'AMOUNT / STATUS')),
                ],
              ),
            ),

            if (filtered.isEmpty)
              const TrustechEmptyState(
                title: 'No Charges Found',
                message: 'Adjust your search or filter.',
                icon: Icons.receipt_long_outlined,
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _ChargeItemRow(charge: filtered[index]);
                },
              ),
            
            const SizedBox(height: 32),
            // KPI Summary Bento
            const _FinanceKpiGrid(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/finance/charges/new'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ChargeItemRow extends StatelessWidget {
  const _ChargeItemRow({required this.charge});
  final Charge charge;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TrustechCard(
      onTap: () => context.push('/finance/charges/${charge.id}'),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                TrustechAvatar(name: charge.studentName, radius: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        charge.studentName,
                        style: TrustechTypography.label.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface),
                      ),
                      Text(
                        'ID: ${charge.studentId}',
                        style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        charge.type,
                        style: TrustechTypography.bodySmall.copyWith(color: cs.outline, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${charge.amount.toStringAsFixed(2)}',
                  style: TrustechTypography.label.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface),
                ),
                const SizedBox(height: 4),
                StatusChip(
                  label: charge.status.label,
                  kind: _getKind(charge.status),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.more_vert, size: 18, color: cs.outline),
        ],
      ),
    );
  }

  StatusKind _getKind(ChargeStatus status) {
    switch (status) {
      case ChargeStatus.paid:
        return StatusKind.success;
      case ChargeStatus.overdue:
        return StatusKind.error;
      case ChargeStatus.partial:
        return StatusKind.warning;
      case ChargeStatus.pending:
        return StatusKind.neutral;
    }
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

class _FinanceKpiGrid extends StatelessWidget {
  const _FinanceKpiGrid();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        const Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'TOTAL OUTSTANDING',
                value: '\$42,910.45',
                icon: Icons.account_balance_wallet_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(
              child: StatCard(
                label: 'OVERDUE COUNT',
                value: '24',
                icon: Icons.assignment_late_outlined,
                accent: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'COLLECTED (MTD)',
                value: '\$182.3k',
                icon: Icons.check_circle_outlined,
                accent: cs.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
