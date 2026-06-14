// Roles: ADMIN (ADMIN: view)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile_pro/src/features/admin/providers/admin_providers.dart';

class EmailLogsScreen extends ConsumerWidget {
  const EmailLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(emailLogsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Email Logs'),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final log = logs[index];
          return TrustechCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  log.status == 'Delivered' ? Icons.check_circle_outline : Icons.error_outline,
                  color: log.status == 'Delivered' ? cs.primary : cs.error,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.subject, style: TrustechTypography.label.copyWith(fontWeight: FontWeight.bold)),
                      Text(log.recipient, style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant)),
                      Text(DateFormat('MMM dd, HH:mm').format(log.timestamp), style: TrustechTypography.caption.copyWith(color: cs.outline)),
                    ],
                  ),
                ),
                StatusChip(label: log.status.toUpperCase(), kind: log.status == 'Delivered' ? StatusKind.success : StatusKind.error),
              ],
            ),
          );
        },
      ),
    );
  }
}
