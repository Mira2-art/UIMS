import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app_shell.dart';
import 'app/bootstrap.dart';
import 'src/core/theme/theme_provider.dart';

void main() async {
  // 1. Initialize dependencies
  final prefs = await bootstrap();

  // 2. Run the app with Riverpod
  runApp(
    ProviderScope(
      overrides: [
        // Override the sharedPreferencesProvider with the actual instance
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const AppShell(),
    ),
  );
}
