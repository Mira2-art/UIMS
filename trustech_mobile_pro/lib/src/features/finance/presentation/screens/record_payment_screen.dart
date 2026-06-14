// Roles: BURSAR (FINANCE: manage)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class RecordPaymentScreen extends ConsumerStatefulWidget {
  const RecordPaymentScreen({super.key});

  @override
  ConsumerState<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends ConsumerState<RecordPaymentScreen> {
  final _amountController = TextEditingController();
  final _receiptController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _receiptController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Record Payment'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Record Payment',
              style: TrustechTypography.displayLarge.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Manually log a student payment received via bank transfer or cash.',
              style: TrustechTypography.bodyLarge.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            
            const SectionHeader(title: 'Student & Transaction'),
            const SizedBox(height: 8),
            TrustechTextField(
              controller: _searchController,
              hintText: 'Search student...',
              prefixIcon: Icons.person_search,
            ),
            const SizedBox(height: 16),
            TrustechTextField(
              controller: _amountController,
              label: 'Amount Paid',
              hintText: '0.00',
              prefixIcon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TrustechTextField(
              controller: _receiptController,
              label: 'Receipt Number',
              hintText: 'e.g. RCP-10292',
              prefixIcon: Icons.receipt,
            ),
            const SizedBox(height: 24),
            
            const SectionHeader(title: 'Payment Details'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Payment Method'),
                  items: const [
                    DropdownMenuItem(value: 'bank', child: Text('Bank Transfer')),
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  ],
                  onChanged: (v) {},
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            TrustechButton(
              label: 'Record Payment',
              icon: Icons.check_circle_outline,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
