import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile/src/core/constants/app_colors.dart';
import 'package:trustech_mobile/src/shared/ui_kit/ui_kit.dart';

/// Verify email — prompt to confirm via link. Matches `student_auth_verify_email_light`.
class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Trustech'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Illustration
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.mark_email_unread_outlined, size: 64, color: cs.primary),
              ),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: cs.onSurface),
                  children: [
                    const TextSpan(text: 'Verify your '),
                    TextSpan(text: 'email', style: TextStyle(color: cs.primary)),
                    const TextSpan(text: '.', style: TextStyle(color: TrustechColors.secondary)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 14, height: 1.5, color: cs.onSurfaceVariant),
                  children: const [
                    TextSpan(text: "We've sent a unique link to "),
                    TextSpan(text: 'alex.weaver@university.edu', style: TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(text: '. Please check your inbox to continue.'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Pending status card
              TrustechCard(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: TrustechColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.hourglass_empty, color: TrustechColors.secondary, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Verification Pending', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface)),
                          const SizedBox(height: 2),
                          Text('Waiting for you to click the link in your email.', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TrustechButton(
                label: 'Send verification link',
                icon: Icons.send,
                // TODO(backend:) POST /auth/send-verification
                onPressed: () => AppSnackbar.success(context, 'Verification link sent'),
              ),
              const SizedBox(height: 12),
              TrustechButton(
                label: 'Change email address',
                variant: TrustechButtonVariant.outline,
                onPressed: () => context.go('/login'),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  "Didn't receive anything? Check your spam folder or try resending the link.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
