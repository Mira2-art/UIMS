/// Abstraction over secure, persistent auth state on the device.
///
/// Holds the JWT pair, lightweight cached user data, and refresh/validation
/// timestamps. This is encrypted key–value storage (flutter_secure_storage),
/// not an offline database — the app keeps no local DB.
abstract class TokenProvider {
  // Tokens
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens(String accessToken, {String? refreshToken});
  Future<void> clearTokens({bool softLogout = false});

  // Session timestamps
  Future<int?> getLastValidatedAt();
  Future<void> setLastValidatedAt(int timestampMs);
  Future<DateTime?> getLastTokenRefreshAt();
  Future<void> setLastTokenRefreshAt(DateTime timestamp);

  // Cached user
  Future<void> saveUserData(Map<String, dynamic> userData);
  Future<Map<String, dynamic>?> getUserData();
  Future<String?> getUserId();
  Future<String?> getUserEmail();
}
