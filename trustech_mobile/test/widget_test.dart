// Smoke test: the app boots and renders the welcome screen.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trustech_mobile/app/app_shell.dart';
import 'package:trustech_mobile/src/core/theme/theme_provider.dart';

void main() {
  testWidgets('App boots to the welcome screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const AppShell(),
      ),
    );
    await tester.pump();

    expect(find.text('Welcome to Trustech'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
