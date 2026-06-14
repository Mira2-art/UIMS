// Roles: BURSAR (FINANCE: manage)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class AwardScholarshipScreen extends ConsumerStatefulWidget {
  const AwardScholarshipScreen({super.key});

  @override
  ConsumerState<AwardScholarshipScreen> createState() => _AwardScholarshipScreenState();
}

class _AwardScholarshipScreenState extends ConsumerState<AwardScholarshipScreen> {
  final _amountController = TextEditingController();
  final _studentController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _studentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Award Scholarship'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Award New Scholarship', style: TrustechTypography.displayLarge.copyWith(color: cs.onSurface)),
            const SizedBox(height: 24),
            
            const SectionHeader(title: 'Student Selection'),
            const SizedBox(height: 8),
            TrustechTextField(
              controller: _studentController,
              hintText: 'Search by Name or ID...', 
              prefixIcon: Icons.person_search,
            ),
            const SizedBox(height: 16),
            
            const SectionHeader(title: 'Grant Details'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(8), border: Border.all(color: cs.outlineVariant)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Select Scholarship Program'),
                  items: const [
                    DropdownMenuItem(value: 'excellence', child: Text('Academic Excellence Grant')),
                    DropdownMenuItem(value: 'stem', child: Text('STEM Innovation Fellowship')),
                  ],
                  onChanged: (v) {},
                ),
              ),
            ),
            const SizedBox(height: 16),
            TrustechTextField(
              controller: _amountController,
              label: 'Award Amount',
              hintText: '0.00',
              prefixIcon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            
            TrustechButton(
              label: 'Award Scholarship',
              icon: Icons.check_circle_outline,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
