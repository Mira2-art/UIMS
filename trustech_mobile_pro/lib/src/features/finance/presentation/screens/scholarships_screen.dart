// Roles: BURSAR (FINANCE: manage)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile_pro/src/features/finance/providers/finance_providers.dart';

class ScholarshipsScreen extends ConsumerWidget {
  const ScholarshipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scholarships = ref.watch(scholarshipsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Finance Portal'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scholarship Management', style: TrustechTypography.displayLarge.copyWith(color: cs.onSurface)),
            const SizedBox(height: 24),
            
            // KPI Summary
            Row(
              children: [
                Expanded(child: StatCard(label: 'TOTAL PROGRAMS', value: scholarships.length.toString(), icon: Icons.school_outlined)),
                const SizedBox(width: 12),
                const Expanded(child: StatCard(label: 'ACTIVE', value: '482', icon: Icons.people_outline, accent: Colors.green)),
              ],
            ),
            const SizedBox(height: 24),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: scholarships.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final s = scholarships[index];
                return TrustechCard(
                  onTap: () {},
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: cs.primaryContainer.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                        child: Icon(Icons.workspace_premium, color: cs.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name, style: TrustechTypography.label.copyWith(fontWeight: FontWeight.bold)),
                            Text('${s.recipientsCount} Recipients', style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${s.totalFund.toInt()}', style: TrustechTypography.label.copyWith(fontWeight: FontWeight.bold)),
                          StatusChip(label: s.status, kind: s.status == 'Active' ? StatusKind.success : StatusKind.neutral),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/finance/scholarships/new'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('New Program'),
      ),
    );
  }
}
