import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

// Roles: all staff (shared entry).
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final email = TextEditingController(text: 'marcus.wright@trustech.edu');

    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Forgot Password',
        actions: [
          IconButton(
            tooltip: 'Help',
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
        children: [
          TrustechCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2D5A68), Color(0xFF3D7A8C)],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Reset Access',
                    style: TrustechTypography.h2.copyWith(color: cs.onSurface)),
                const SizedBox(height: 8),
                Text(
                  "Enter your staff email address below and we'll send you a secure link to reset your password.",
                  textAlign: TextAlign.center,
                  style: TrustechTypography.bodySmall.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                TrustechTextField(
                  controller: email,
                  label: 'EMAIL',
                  prefixIcon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),
                TrustechButton(
                  label: 'Send Reset Link',
                  trailingIcon: Icons.send,
                  onPressed: () {
                    // TODO(backend): POST /auth/forgot-password.
                    AppSnackbar.success(context, 'Reset link sent to your inbox.');
                    context.push('/reset-password');
                  },
                ),
                const SizedBox(height: 14),
                TextButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Icons.chevron_left, size: 18),
                  label: const Text('Back to Login'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'If you no longer have access to your email, please contact the IT Administration desk at extension 8842.',
            textAlign: TextAlign.center,
            style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
