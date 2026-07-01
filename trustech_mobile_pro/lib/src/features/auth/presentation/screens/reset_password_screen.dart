import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

// Roles: all staff (shared entry).
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Reset Password'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.lock_reset_outlined, color: cs.primary, size: 30),
                const SizedBox(height: 8),
                Text(
                  'Enter the 6-digit code sent to your email and choose a secure new password.',
                  textAlign: TextAlign.center,
                  style: TrustechTypography.bodySmall.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TrustechCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TrustechTextField(
                  controller: _code,
                  label: 'Reset Code',
                  hintText: '0 0 0 0 0 0',
                  prefixIcon: Icons.mail_outline,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TrustechTextField(
                  controller: _password,
                  label: 'New Password',
                  obscureText: true,
                  prefixIcon: Icons.vpn_key_outlined,
                ),
                const SizedBox(height: 16),
                TrustechTextField(
                  controller: _confirm,
                  label: 'Confirm New Password',
                  obscureText: true,
                  prefixIcon: Icons.shield_outlined,
                ),
                const SizedBox(height: 16),
                const _Requirements(),
                const SizedBox(height: 18),
                TrustechButton(
                  label: 'Reset Password',
                  trailingIcon: Icons.lock_reset,
                  onPressed: () {
                    // TODO(backend): POST /auth/reset-password.
                    AppSnackbar.success(context, 'Password reset. Please sign in.');
                    context.go('/login');
                  },
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: "Didn't receive a code? ",
                      style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant),
                      children: [
                        TextSpan(
                          text: 'Resend Email',
                          style: TrustechTypography.caption
                              .copyWith(color: cs.primary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Requirements extends StatelessWidget {
  const _Requirements();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const reqs = [
      'Minimum 8 characters',
      'At least one uppercase letter',
      'At least one number or symbol',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text('PASSWORD REQUIREMENTS',
                  style: TrustechTypography.overline.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 8),
          for (final r in reqs)
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 4),
              child: Text('•  $r',
                  style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant)),
            ),
        ],
      ),
    );
  }
}
