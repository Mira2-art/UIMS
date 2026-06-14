import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

// Roles: all staff (shared entry).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrandGradientHeader(
        height: double.infinity,
        padding: EdgeInsets.zero,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.school, color: Colors.white, size: 34),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Trustech Staff',
                  textAlign: TextAlign.center,
                  style: TrustechTypography.displayLarge.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  'Manage courses, attendance, grades and students — all in one place.',
                  textAlign: TextAlign.center,
                  style: TrustechTypography.bodyLarge
                      .copyWith(color: Colors.white.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: 28),
                const _PortalCard(),
                const Spacer(flex: 3),
                TrustechButton(
                  label: 'Get Started',
                  trailingIcon: Icons.arrow_forward,
                  variant: TrustechButtonVariant.secondary,
                  onPressed: () => context.go('/login'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.go('/login'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Login', style: TrustechTypography.button),
                ),
                const SizedBox(height: 18),
                Text(
                  'Trusted by 500+ academic institutions worldwide.',
                  textAlign: TextAlign.center,
                  style: TrustechTypography.caption
                      .copyWith(color: Colors.white.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PortalCard extends StatelessWidget {
  const _PortalCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(Icons.insights_outlined,
              color: Colors.white.withValues(alpha: 0.9), size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('STAFF PORTAL V2.0',
                    style: TrustechTypography.overline.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text('Integrated Gradebooks & Real-time Analytics',
                    style: TrustechTypography.bodySmall
                        .copyWith(color: Colors.white.withValues(alpha: 0.85))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
