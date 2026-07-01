import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile/src/core/auth/session_controller.dart';
import 'package:trustech_mobile/src/core/constants/app_colors.dart';
import 'package:trustech_mobile/src/shared/ui_kit/ui_kit.dart';

/// Branded splash. Bootstraps the session (restores a saved login), then routes
/// to /home if authenticated or /welcome otherwise.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await ref.read(sessionProvider.notifier).bootstrap();
    if (!mounted) return;
    final authed = ref.read(sessionProvider).isAuthenticated;
    context.go(authed ? '/home' : '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: BrandGradientHeader(
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school_rounded, size: 80, color: TrustechColors.secondary),
              SizedBox(height: 20),
              Text(
                'Trustech',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
