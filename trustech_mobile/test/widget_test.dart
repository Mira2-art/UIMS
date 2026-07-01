// Smoke test: the app boots to splash, then advances to the welcome screen
// (no stored session → unauthenticated).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trustech_mobile/app/app_shell.dart';
import 'package:trustech_mobile/src/core/storage/secure_storage.dart';
import 'package:trustech_mobile/src/core/storage/token_provider.dart';
import 'package:trustech_mobile/src/core/theme/theme_provider.dart';

/// In-memory token store so tests don't touch the secure-storage plugin.
class _FakeTokenStore implements TokenProvider {
  String? _access;
  @override
  Future<String?> getAccessToken() async => _access;
  @override
  Future<String?> getRefreshToken() async => null;
  @override
  Future<void> saveTokens(String accessToken, {String? refreshToken}) async =>
      _access = accessToken;
  @override
  Future<void> clearTokens({bool softLogout = false}) async => _access = null;
  @override
  Future<int?> getLastValidatedAt() async => null;
  @override
  Future<void> setLastValidatedAt(int timestampMs) async {}
  @override
  Future<DateTime?> getLastTokenRefreshAt() async => null;
  @override
  Future<void> setLastTokenRefreshAt(DateTime timestamp) async {}
  @override
  Future<void> saveUserData(Map<String, dynamic> userData) async {}
  @override
  Future<Map<String, dynamic>?> getUserData() async => null;
  @override
  Future<String?> getUserId() async => null;
  @override
  Future<String?> getUserEmail() async => null;
}

void main() {
  testWidgets('App boots to splash then welcome', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenStoreProvider.overrideWithValue(_FakeTokenStore()),
        ],
        child: const AppShell(),
      ),
    );

    // Splash
    await tester.pump();
    expect(find.text('Trustech'), findsOneWidget);

    // Bootstrap resolves (no token → unauthenticated) → navigates to /welcome.
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('Welcome to Trustech'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
