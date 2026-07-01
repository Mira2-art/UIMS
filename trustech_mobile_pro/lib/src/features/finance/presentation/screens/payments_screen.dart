// Roles: BURSAR (FINANCE: manage)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile_pro/src/features/finance/providers/finance_providers.dart';
import 'package:trustech_mobile_pro/src/features/finance/data/mock/finance_mock.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final payments = ref.watch(paymentsProvider);
    final cs = Theme.of(context).colorScheme;

    final filtered = payments.where((p) {
      final q = _searchQuery.toLowerCase();
      return p.studentName.toLowerCase().contains(q) || p.studentId.toLowerCase().contains(q) || p.receiptNo.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Finance Portal'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary
            const _FinanceKpiGrid(),
            const SizedBox(height: 24),

            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by Student Name, ID or Receipt...',
                prefixIcon: const Icon(Icons.search),
                fillColor: cs.surfaceContainerLow,
              ),
            ),

            const SizedBox(height: 24),

            // Payment Table/List
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(flex: 4, child: _HeaderText(label: 'STUDENT / RECEIPT')),
                  Expanded(flex: 3, child: _HeaderText(label: 'AMOUNT / METHOD')),
                ],
              ),
            ),

            if (filtered.isEmpty)
              const TrustechEmptyState(
                title: 'No Payments Found',
                message: 'Adjust your search query.',
                icon: Icons.payments_outlined,
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _PaymentRow(payment: filtered[index]);
                },
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/finance/payments/new'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Record Payment'),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});
  final Payment payment;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TrustechCard(
      onTap: () => context.push('/finance/payments/${payment.id}'),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                TrustechAvatar(name: payment.studentName, radius: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.studentName,
                        style: TrustechTypography.label.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface),
                      ),
                      Text(
                        'Receipt: ${payment.receiptNo}',
                        style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant),
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
                  '\$${payment.amount.toStringAsFixed(2)}',
                  style: TrustechTypography.label.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
                ),
                Text(
                  payment.method,
                  style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
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

class _FinanceKpiGrid extends StatelessWidget {
  const _FinanceKpiGrid();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'TOTAL VOLUME',
            value: '\$124.5k',
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: StatCard(
            label: 'VERIFIED TODAY',
            value: '42',
            icon: Icons.check_circle_outline,
          ),
        ),
      ],
    );
  }
}

