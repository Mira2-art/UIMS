import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile/src/core/constants/app_colors.dart';
import 'package:trustech_mobile/src/shared/ui_kit/ui_kit.dart';

/// Reset password — enter code + new credentials. Matches `student_auth_reset_password_light`.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    // TODO(backend:) POST /auth/reset-password
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _submitting = false);
    AppSnackbar.success(context, 'Password updated. Please sign in.');
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppHeaderBar.back(title: 'Trustech', showNotification: true, onNotification: () {}),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Illustration
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.lock_reset, color: TrustechColors.primary, size: 32),
                      ),
                      const Positioned(
                        right: -2,
                        top: -2,
                        child: CircleAvatar(radius: 4, backgroundColor: TrustechColors.secondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Reset Password', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: cs.onSurface)),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit code sent to your student email and set your new credentials.',
                style: TextStyle(fontSize: 14, height: 1.5, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              TrustechTextField(
                controller: _code,
                label: 'Verification Code',
                hintText: '000000',
                prefixIcon: Icons.vpn_key_outlined,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TrustechTextField(
                controller: _password,
                label: 'New Password',
                hintText: '••••••••',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TrustechTextField(
                controller: _confirm,
                label: 'Confirm Password',
                hintText: '••••••••',
                prefixIcon: Icons.shield_outlined,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ReqChip('8+ Characters'),
                  _ReqChip('Numbers'),
                  _ReqChip('Special Char'),
                ],
              ),
              const SizedBox(height: 20),
              TrustechButton(
                label: 'Update Password',
                trailingIcon: Icons.swap_horiz,
                isLoading: _submitting,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text("Didn't receive a code? ", style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
                    GestureDetector(
                      onTap: () {},
                      child: const Text('Resend Code', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: TrustechColors.secondary)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReqChip extends StatelessWidget {
  const _ReqChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
