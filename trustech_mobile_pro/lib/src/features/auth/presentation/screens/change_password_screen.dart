import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

// Roles: all staff (shared entry).
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Change Password'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_reset_outlined, color: cs.primary, size: 38),
            ),
          ),
          const SizedBox(height: 14),
          Text('Security Update',
              textAlign: TextAlign.center,
              style: TrustechTypography.h2.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          Text(
            "Ensure your account stays secure by choosing a strong, unique password that you don't use elsewhere.",
            textAlign: TextAlign.center,
            style: TrustechTypography.bodySmall.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          TrustechCard(
            child: Column(
              children: [
                TrustechTextField(
                  controller: _current,
                  label: 'Current Password',
                  hintText: 'Enter current password',
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TrustechTextField(
                  controller: _next,
                  label: 'New Password',
                  hintText: 'Min. 8 characters long',
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TrustechTextField(
                  controller: _confirm,
                  label: 'Confirm New Password',
                  hintText: 'Repeat new password',
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                const _Reqs(),
                const SizedBox(height: 18),
                TrustechButton(
                  label: 'Update Password',
                  trailingIcon: Icons.check_circle_outline,
                  onPressed: () {
                    // TODO(backend): POST /auth/change-password.
                    AppSnackbar.success(context, 'Password updated.');
                    context.pop();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: TextButton.icon(
              onPressed: () => context.push('/forgot-password'),
              icon: const Icon(Icons.help_outline, size: 18),
              label: const Text('Forgotten your current password?'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Reqs extends StatelessWidget {
  const _Reqs();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const items = [
      ('At least 8 characters long', true),
      ('Include one special character', false),
      ('Include one uppercase letter', false),
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
          Text('REQUIREMENTS',
              style: TrustechTypography.overline.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          for (final (label, met) in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(met ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 16, color: met ? cs.primary : cs.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(label,
                        style: TrustechTypography.caption.copyWith(color: cs.onSurface)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
