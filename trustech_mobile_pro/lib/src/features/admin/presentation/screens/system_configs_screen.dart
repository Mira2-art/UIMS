// Roles: ADMIN (ADMIN: view)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile_pro/src/features/admin/providers/admin_providers.dart';

class SystemConfigsScreen extends ConsumerWidget {
  const SystemConfigsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(systemConfigsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'System Configurations'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('System Configurations', style: TrustechTypography.displayLarge.copyWith(color: cs.onSurface)),
            const SizedBox(height: 8),
            Text('Read-only view of current system parameter settings.', style: TrustechTypography.bodyLarge.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 24),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: configs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final config = configs[index];
                return TrustechCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(config.name, style: TrustechTypography.label.copyWith(fontWeight: FontWeight.bold)),
                          Text(config.description, style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                      Text(config.value, style: TrustechTypography.h3.copyWith(color: cs.primary)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
