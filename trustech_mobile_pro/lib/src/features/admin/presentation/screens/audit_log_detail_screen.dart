// Roles: ADMIN (ADMIN: view)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile_pro/src/features/admin/providers/admin_providers.dart';

class AuditLogDetailScreen extends ConsumerWidget {
  const AuditLogDetailScreen({super.key, required this.auditId});

  final String auditId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(auditLogDetailProvider(auditId));
    final cs = Theme.of(context).colorScheme;

    if (log == null) {
      return const TrustechScaffold(
        title: 'Log Detail',
        body: Center(child: Text('Log entry not found')),
      );
    }

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Log Detail'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: TrustechCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ACTION', style: TrustechTypography.overline.copyWith(color: cs.outline)),
              Text(log.action, style: TrustechTypography.h2.copyWith(color: cs.onSurface)),
              const SizedBox(height: 24),
              InfoListCard(
                children: [
                  InfoListRow(title: 'User', subtitle: log.user, icon: Icons.person_outline),
                  InfoListRow(title: 'Severity', subtitle: log.severity, icon: Icons.flag_outlined),
                  InfoListRow(
                    title: 'Timestamp',
                    subtitle: DateFormat('MMM dd, yyyy HH:mm').format(log.timestamp),
                    icon: Icons.schedule,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
