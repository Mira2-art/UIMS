// Roles: BURSAR (FINANCE: manage)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class BillStudentScreen extends ConsumerStatefulWidget {
  const BillStudentScreen({super.key});

  @override
  ConsumerState<BillStudentScreen> createState() => _BillStudentScreenState();
}

class _BillStudentScreenState extends ConsumerState<BillStudentScreen> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Bill Student'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bill Student',
              style: TrustechTypography.displayLarge.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate a single-student fee charge or invoice manually.',
              style: TrustechTypography.bodyLarge.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            
            // Student Search
            const SectionHeader(title: 'Student Search'),
            const SizedBox(height: 8),
            TrustechTextField(
              controller: _searchController,
              hintText: 'Search by Name or ID...',
              prefixIcon: Icons.search,
            ),
            const SizedBox(height: 24),

            // Fee Category
            const SectionHeader(title: 'Fee Category'),
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
                  hint: const Text('Select a Category'),
                  items: const [
                    DropdownMenuItem(value: 'tuition', child: Text('Tuition Fees')),
                    DropdownMenuItem(value: 'lab', child: Text('Laboratory & Equipment')),
                  ],
                  onChanged: (v) {},
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Amount & Due Date
            Row(
              children: [
                Expanded(
                  child: TrustechTextField(
                    controller: _amountController,
                    label: 'Custom Amount',
                    hintText: '0.00',
                    prefixIcon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Due Date', style: TrustechTypography.label.copyWith(color: cs.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: InkWell(
                          onTap: () {},
                          child: const Row(
                            children: [
                              SizedBox(width: 12),
                              Icon(Icons.calendar_today, size: 20),
                              SizedBox(width: 8),
                              Text('Select Date'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description
            TrustechTextField(
              controller: _descController,
              label: 'Description',
              hintText: 'Provide details for the invoice...',
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // Invoice Preview (design parity)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.receipt_long_outlined, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invoice Preview',
                          style: TrustechTypography.label.copyWith(color: cs.onSurface),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'A digital invoice will be emailed to the student and recorded '
                          'in the current fiscal period upon generation.',
                          style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            TrustechButton(
              label: 'Generate Invoice',
              icon: Icons.receipt_long,
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            TrustechButton(
              label: 'Cancel',
              variant: TrustechButtonVariant.text,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}
