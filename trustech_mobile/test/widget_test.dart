// Smoke test: the app boots to splash, then advances to the welcome screen.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trustech_mobile/app/app_shell.dart';
import 'package:trustech_mobile/src/core/theme/theme_provider.dart';

void main() {
  testWidgets('App boots to splash then welcome', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const AppShell(),
      ),
    );

    // Splash
    await tester.pump();
    expect(find.text('Trustech'), findsOneWidget);

    // Advance past the splash delay → navigates to /welcome
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('Welcome to Trustech'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
