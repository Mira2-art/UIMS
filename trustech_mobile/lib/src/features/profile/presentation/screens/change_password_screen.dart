import 'package:flutter/material.dart';

import '../../../../shared/ui_kit/ui_kit.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    // TODO(backend): implement password change
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SuccessStateCard(
        title: 'Password Updated',
        subtitle:
            'Your password has been successfully changed. Please use your new credentials for future logins.',
      ),
    );
    // Auto-pop after 2 seconds or wait for user
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(); // pop dialog
        Navigator.of(context).pop(); // back to settings/profile
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const AppHeaderBar.back(
        title: 'Change Password',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Illustration Card
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.primaryContainer.withValues(alpha: 0.2)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      Icons.lock_person_outlined,
                      size: 140,
                      color: cs.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'SECURITY UPDATE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Keep your account secure by using a strong, unique password.',
                          style: TextStyle(
                            fontSize: 14,
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Form
            TrustechTextField(
              controller: _currentController,
              label: 'Current Password',
              hintText: 'Enter current password',
              obscureText: true,
              prefixIcon: Icons.lock_outline,
            ),
            const SizedBox(height: 20),
            TrustechTextField(
              controller: _newController,
              label: 'New Password',
              hintText: 'Create new password',
              obscureText: true,
              prefixIcon: Icons.vpn_key_outlined,
              onChanged: (v) => setState(() {}),
            ),
            const SizedBox(height: 8),
            // Strength Indicator
            _PasswordStrengthBar(password: _newController.text),
            const SizedBox(height: 4),
            Text(
              'At least 8 characters, including letters and numbers.',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            TrustechTextField(
              controller: _confirmController,
              label: 'Confirm New Password',
              hintText: 'Repeat new password',
              obscureText: true,
              prefixIcon: Icons.lock_reset_outlined,
            ),
            const SizedBox(height: 40),

            TrustechButton(
              label: 'Change Password',
              icon: Icons.lock_open,
              onPressed: _handleSubmit,
            ),
            const SizedBox(height: 12),
            TrustechButton(
              label: 'Cancel',
              variant: TrustechButtonVariant.outline,
              onPressed: () => Navigator.of(context).pop(),
            ),

            const SizedBox(height: 32),
            // Security Tip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: cs.secondary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security Tip',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'We recommend changing your password every 6 months to maintain high account security.',
                          style: TextStyle(
                            fontSize: 14,
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.password});
  final String password;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final strength = _calculateStrength();

    return Row(
      children: List.generate(4, (index) {
        final isActive = index < strength;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index == 3 ? 0 : 4),
            decoration: BoxDecoration(
              color: isActive ? _getStrengthColor(strength, cs) : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  int _calculateStrength() {
    if (password.isEmpty) return 0;
    int s = 1;
    if (password.length >= 8) s++;
    if (RegExp(r'[0-9]').hasMatch(password)) s++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) s++;
    return s;
  }

  Color _getStrengthColor(int strength, ColorScheme cs) {
    if (strength <= 1) return cs.error;
    if (strength <= 2) return cs.secondary;
    if (strength <= 3) return Colors.orange;
    return Colors.green;
  }
}
