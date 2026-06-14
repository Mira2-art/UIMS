import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

// Roles: all staff (shared entry). Refined login variant.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: 'name@trustech.edu');
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    // TODO(backend): POST /auth/login with X-Client-ID + device_info.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Column(
        children: [
          AnnouncementBanner(
            message: 'New Announcement: Fall 2024 Exam Schedule',
            onAction: () {},
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(Icons.school, color: cs.primary, size: 34),
                  ),
                  const SizedBox(height: 16),
                  Text('Welcome back',
                      style: TrustechTypography.displayLarge.copyWith(color: cs.onSurface)),
                  const SizedBox(height: 6),
                  Text('Sign in to your staff account',
                      style: TrustechTypography.bodyMedium
                          .copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  TrustechCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TrustechTextField(
                          controller: _email,
                          label: 'Email',
                          hintText: 'name@trustech.edu',
                          prefixIcon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Password',
                                style: TrustechTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600, color: cs.onSurface)),
                            GestureDetector(
                              onTap: () => context.push('/forgot-password'),
                              child: Text('Forgot password?',
                                  style: TrustechTypography.caption.copyWith(
                                      color: cs.primary, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TrustechTextField(
                          controller: _password,
                          hintText: '••••••••',
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                        ),
                        const SizedBox(height: 20),
                        TrustechButton(
                          label: 'Sign in',
                          trailingIcon: Icons.login,
                          isLoading: _loading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('OR LOGIN WITH',
                                  style: TrustechTypography.overline
                                      .copyWith(color: cs.onSurfaceVariant)),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TrustechButton(
                          label: 'Google Workspace',
                          icon: Icons.g_mobiledata,
                          variant: TrustechButtonVariant.outline,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'By signing in, you agree to the Trustech Academic Platform Terms of Service and Privacy Guidelines for Faculty and Staff.',
                    textAlign: TextAlign.center,
                    style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
