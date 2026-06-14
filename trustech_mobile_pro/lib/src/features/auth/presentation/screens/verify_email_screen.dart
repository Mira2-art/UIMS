import 'package:flutter/material.dart';

import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

// Roles: all staff (shared entry).
class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Verify Email',
        actions: [
          IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.verified_user_outlined, color: cs.error, size: 40),
            ),
          ),
          const SizedBox(height: 12),
          const Center(child: StatusChip(label: 'Unverified', kind: StatusKind.error)),
          const SizedBox(height: 14),
          Text('Secure Your Account',
              textAlign: TextAlign.center,
              style: TrustechTypography.h2.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          Text(
            'To access the educator workspace and administrative tools, you must verify the email address associated with your staff profile.',
            textAlign: TextAlign.center,
            style: TrustechTypography.bodySmall.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          TrustechCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.mail_outline, color: cs.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CURRENT EMAIL',
                              style: TrustechTypography.overline
                                  .copyWith(color: cs.onSurfaceVariant)),
                          Text('m.wright@trustech.edu',
                              style: TrustechTypography.bodyMedium
                                  .copyWith(color: cs.onSurface)),
                        ],
                      ),
                    ),
                    TextButton(onPressed: () {}, child: const Text('Change')),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  "The verification link will expire in 24 hours. If you don't see the email within 5 minutes, you can request a new link.",
                  style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                TrustechButton(
                  label: 'Send Verification Email',
                  icon: Icons.send,
                  onPressed: () {
                    // TODO(backend): POST /auth/send-verification.
                    AppSnackbar.success(context, 'Verification email sent.');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const InfoListCard(
            children: [
              InfoListRow(
                title: 'Data Protection',
                subtitle: 'Verification ensures only authorized staff can access student records.',
                icon: Icons.security_outlined,
              ),
              InfoListRow(
                title: 'Auto-Sync',
                subtitle: 'Once verified, your workspace syncs across all devices instantly.',
                icon: Icons.sync,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Trouble verifying? Contact IT Support',
              textAlign: TextAlign.center,
              style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
