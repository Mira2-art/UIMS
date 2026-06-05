import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trustech_mobile/src/core/constants/app_colors.dart';
import 'package:trustech_mobile/src/core/constants/dimensions.dart';

/// Brand hero / entry screen. The teal→dark-teal gradient with white text is an
/// intentional, fixed brand surface, so colours here are deliberate rather than
/// theme-driven.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              TrustechColors.primary,
              Color(0xFF2D5A68), // Darker shade of brand teal
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo placeholder
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 80,
                    color: TrustechColors.secondary,
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  'Welcome to Trustech',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Empowering education through seamless digital management and tracking.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const Spacer(flex: 3),

                // Primary action — amber accent on the teal hero
                SizedBox(
                  width: double.infinity,
                  height: kLargeButtonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: navigate to login/register
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TrustechColors.secondary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: const Text(
                      'Get Started',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: kLargeButtonHeight,
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: navigate to login
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Login to Account',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  '© 2026 Trustech Technologies',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
