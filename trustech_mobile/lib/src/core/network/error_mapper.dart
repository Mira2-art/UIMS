import 'package:dio/dio.dart';

/// Maps a thrown error (usually a [DioException]) to a short, user-facing message.
String friendlyError(Object error) {
  if (error is DioException) {
    final code = error.response?.statusCode;
    final data = error.response?.data;
    // FastAPI returns {"detail": "..."} (or a list of validation errors).
    if (data is Map && data['detail'] is String) {
      return data['detail'] as String;
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'The server took too long to respond. Check your connection.';
      case DioExceptionType.connectionError:
        return 'Could not reach the server. Make sure you are on the right network.';
      default:
        break;
    }
    if (code == 401) return 'Invalid email or password.';
    if (code == 403) return 'You do not have access to this.';
    if (code == 404) return 'Not found.';
    if (code != null && code >= 500) return 'Server error. Please try again.';
    return 'Something went wrong. Please try again.';
  }
  return 'Something went wrong. Please try again.';
}
