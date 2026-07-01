import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env_config.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/client/dio_provider.dart';

/// Calls the backend `/auth/*` endpoints. The Dio interceptor already attaches
/// `X-Client-ID`; login/register additionally send `client_id` in the body.
class AuthService {
  AuthService(this._dio, this._clientId);

  final Dio _dio;
  final String _clientId;

  /// Returns `{access_token, refresh_token}` on success.
  Future<({String access, String? refresh})> login(
    String email,
    String password,
  ) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.signin,
      data: {'email': email, 'password': password, 'client_id': _clientId},
    );
    final data = res.data ?? const {};
    return (
      access: data['access_token'] as String,
      refresh: data['refresh_token'] as String?,
    );
  }

  Future<void> logout() async {
    try {
      await _dio.post<void>(ApiEndpoints.logout);
    } on DioException {
      // Best-effort; local tokens are cleared regardless.
    }
  }

  Future<void> forgotPassword(String email) =>
      _dio.post<void>(ApiEndpoints.forgotPassword, data: {'email': email});

  Future<void> changePassword(String currentPassword, String newPassword) =>
      _dio.post<void>(
        ApiEndpoints.changePassword,
        data: {'current_password': currentPassword, 'new_password': newPassword},
      );
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(dioProvider), ref.watch(envProvider).clientId);
});
