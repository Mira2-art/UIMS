import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

/// Sample feature screen demonstrating the shared UI Kit + theming.
///
/// This is a UI scaffold only — wire it to the auth provider/service when the
/// auth feature is implemented.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
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
    setState(() => _submitting = true);
    // Placeholder: simulate a request. Replace with the auth service call.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _submitting = false);
    AppSnackbar.info(context, 'Auth not wired yet — sample screen only.');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TrustechScaffold(
      title: 'Sign in',
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Icon(Icons.school_rounded, size: 56, color: cs.primary),
          const SizedBox(height: 16),
          Text(
            'Welcome back',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sign in to your staff account',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          TrustechTextField(
            controller: _email,
            label: 'Email',
            hintText: 'you@school.edu',
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
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TrustechButton(
              label: 'Forgot password?',
              variant: TrustechButtonVariant.text,
              expand: false,
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 16),
          TrustechButton(
            label: 'Sign in',
            icon: Icons.login,
            isLoading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
