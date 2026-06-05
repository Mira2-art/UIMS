import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_provider.dart';

const _kAccessTokenKey = 'access_token';
const _kRefreshTokenKey = 'refresh_token';
const _kLastValidatedAtKey = 'last_validated_at';
const _kLastTokenRefreshAtKey = 'last_token_refresh_at';
const _kUserDataKey = 'user_data';
const _kUserIdKey = 'user_id';
const _kUserEmailKey = 'user_email';

/// [TokenProvider] backed by the platform secure enclave / keystore.
class SecureTokenStore implements TokenProvider {
  SecureTokenStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> getAccessToken() => _storage.read(key: _kAccessTokenKey);

  @override
  Future<String?> getRefreshToken() => _storage.read(key: _kRefreshTokenKey);

  @override
  Future<void> saveTokens(String accessToken, {String? refreshToken}) async {
    await _storage.write(key: _kAccessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _kRefreshTokenKey, value: refreshToken);
    }
  }

  @override
  Future<void> clearTokens({bool softLogout = false}) async {
    await _storage.delete(key: _kAccessTokenKey);
    await _storage.delete(key: _kRefreshTokenKey);
    await _storage.delete(key: _kLastValidatedAtKey);
    await _storage.delete(key: _kUserDataKey);
    await _storage.delete(key: _kUserIdKey);
    await _storage.delete(key: _kUserEmailKey);

    if (!softLogout) {
      await _storage.delete(key: _kLastTokenRefreshAtKey);
    }
  }

  @override
  Future<int?> getLastValidatedAt() async {
    final value = await _storage.read(key: _kLastValidatedAtKey);
    return value != null ? int.tryParse(value) : null;
  }

  @override
  Future<void> setLastValidatedAt(int timestampMs) =>
      _storage.write(key: _kLastValidatedAtKey, value: timestampMs.toString());

  @override
  Future<DateTime?> getLastTokenRefreshAt() async {
    final value = await _storage.read(key: _kLastTokenRefreshAtKey);
    return value != null ? DateTime.tryParse(value) : null;
  }

  @override
  Future<void> setLastTokenRefreshAt(DateTime timestamp) => _storage.write(
        key: _kLastTokenRefreshAtKey,
        value: timestamp.toIso8601String(),
      );

  @override
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _storage.write(key: _kUserDataKey, value: jsonEncode(userData));
    final id = userData['user_id'] ?? userData['id'];
    if (id != null) {
      await _storage.write(key: _kUserIdKey, value: id.toString());
    }
    if (userData['email'] != null) {
      await _storage.write(key: _kUserEmailKey, value: userData['email'].toString());
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final value = await _storage.read(key: _kUserDataKey);
    if (value == null) return null;
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getUserId() => _storage.read(key: _kUserIdKey);

  @override
  Future<String?> getUserEmail() => _storage.read(key: _kUserEmailKey);
}

final tokenStoreProvider = Provider<TokenProvider>((ref) => SecureTokenStore());
