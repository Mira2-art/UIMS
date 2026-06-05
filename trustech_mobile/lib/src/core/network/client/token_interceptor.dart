import 'package:dio/dio.dart';

import '../../storage/token_provider.dart';
import '../api_endpoints.dart';

/// Attaches auth credentials to every outgoing request:
///  * `Authorization: Bearer <access token>` (when present and not a public path)
///  * `X-Client-ID: <client id>` on every request — the backend verifies this
///    against the registered client app and the token's `cid` claim.
///
/// On a 401 from a protected endpoint it clears the local session (simple
/// auto-logout). Token refresh can be layered in here later.
class TokenInterceptor extends QueuedInterceptor {
  TokenInterceptor(this._tokenProvider, this._clientId);

  final TokenProvider _tokenProvider;
  final String _clientId;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Client identification — required on every request by the backend.
    options.headers['X-Client-ID'] = _clientId;

    final isPublic = ApiEndpoints.publicAuthPaths.contains(options.path);
    if (!isPublic) {
      final token = await _tokenProvider.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    if (ApiEndpoints.publicAuthPaths.contains(err.requestOptions.path)) {
      return handler.next(err);
    }

    // Session is no longer valid — clear it. Routing/guards react to the cleared
    // token and send the user back to the auth flow.
    await _tokenProvider.clearTokens();
    handler.next(err);
  }
}
