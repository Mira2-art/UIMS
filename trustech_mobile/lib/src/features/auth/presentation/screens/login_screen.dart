import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile/src/core/auth/session_controller.dart';
import 'package:trustech_mobile/src/core/constants/app_colors.dart';
import 'package:trustech_mobile/src/core/network/error_mapper.dart';
import 'package:trustech_mobile/src/shared/ui_kit/ui_kit.dart';

/// Sign-in screen — logs in against the backend, then routes to Home.
/// Matches `student_auth_login_light`.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      AppSnackbar.warning(context, 'Enter your email and password.');
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(sessionProvider.notifier).login(email, password);
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Wordmark
              const _Wordmark(),
              const SizedBox(height: 20),
              Text(
                'Sign In',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: cs.onSurface),
              ),
              const SizedBox(height: 6),
              Text(
                'Welcome back to your academic portal.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 28),

              // Card
              TrustechCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TrustechTextField(
                      controller: _email,
                      label: 'Email Address',
                      hintText: 'student@university.edu',
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: 16),
                    TrustechTextField(
                      controller: _password,
                      label: 'Password',
                      hintText: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => context.push('/forgot-password'),
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TrustechButton(
                      label: 'Sign in',
                      isLoading: _submitting,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Divider(color: cs.outlineVariant)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('OR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant)),
                        ),
                        Expanded(child: Divider(color: cs.outlineVariant)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TrustechButton(
                      label: 'Edu-Connect Login',
                      variant: TrustechButtonVariant.outline,
                      icon: Icons.school_outlined,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ", style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
                  GestureDetector(
                    onTap: () {},
                    child: Text('Contact Registry', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cs.primary)),
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

/// "Trustech" wordmark with the amber accent dot.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Trustech',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: cs.primary, letterSpacing: -0.3),
          ),
          const TextSpan(
            text: '.',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: TrustechColors.secondary),
          ),
        ],
      ),
    );
  }
}
