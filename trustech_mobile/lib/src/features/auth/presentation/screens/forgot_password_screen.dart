import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile/src/core/constants/app_colors.dart';
import 'package:trustech_mobile/src/shared/data/mock.dart';
import 'package:trustech_mobile/src/shared/ui_kit/ui_kit.dart';

/// Forgot password — request a reset code. Matches `student_auth_forgot_password_light`.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    // TODO(backend:) POST /auth/forgot-password
    await mockDelay(true, const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _submitting = false);
    context.push('/reset-password');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const AppHeaderBar.back(title: ''),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.school_rounded, color: TrustechColors.primary, size: 28),
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: TrustechColors.secondary, shape: BoxShape.circle),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Forgot Password?', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: cs.onSurface)),
              const SizedBox(height: 10),
              Text(
                "Enter the email address associated with your student account and we'll send you a verification code to reset your password.",
                style: TextStyle(fontSize: 14, height: 1.5, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              const _AuthIllustration(icon: Icons.laptop_chromebook_outlined),
              const SizedBox(height: 24),
              TrustechTextField(
                controller: _email,
                label: 'University Email',
                hintText: 'e.g., student.name@university.edu',
                prefixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 20),
              TrustechButton(
                label: 'Send reset code',
                trailingIcon: Icons.send,
                isLoading: _submitting,
                onPressed: _submit,
              ),
              const SizedBox(height: 20),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text('Still having trouble? ', style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
                    GestureDetector(
                      onTap: () {},
                      child: Text('Contact IT Support', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cs.primary)),
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

class _AuthIllustration extends StatelessWidget {
  const _AuthIllustration({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, size: 56, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
    );
  }
}
