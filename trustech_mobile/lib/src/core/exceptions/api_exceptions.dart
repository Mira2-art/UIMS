import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => message;

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: "Connection timed out. Please check your internet.",
        );
      case DioExceptionType.badResponse:
        return _handleErrorResponse(error.response);
      case DioExceptionType.cancel:
        return ApiException(message: "Request execution was cancelled.");
      case DioExceptionType.connectionError:
        return ApiException(message: "No internet connection.");
      default:
        return ApiException(message: "Something went wrong. Please try again.");
    }
  }

  static ApiException _handleErrorResponse(Response? response) {
    if (response == null) {
      return ApiException(message: "Unknown server error.");
    }

    final statusCode = response.statusCode;
    final data = response.data;

    String errorMessage = "Error: $statusCode";
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String) {
        errorMessage = detail;
      } else if (detail is List && detail.isNotEmpty) {
        // FastAPI validation errors: [{loc, msg, type}, ...]
        final first = detail.first;
        if (first is Map && first['msg'] != null) {
          errorMessage = first['msg'].toString();
        }
      } else {
        errorMessage = data['message'] ?? data['error'] ?? errorMessage;
      }
    }

    return ApiException(
      message: errorMessage,
      statusCode: statusCode,
      data: data,
    );
  }
}
