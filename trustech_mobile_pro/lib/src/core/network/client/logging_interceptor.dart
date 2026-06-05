import 'dart:developer' as dev;
import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  final bool enabled;

  LoggingInterceptor({this.enabled = true});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled) {
      dev.log('→ ${options.method} ${options.uri}', name: 'HTTP');
      if (options.data != null) {
        dev.log('  Body: ${options.data}', name: 'HTTP');
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (enabled) {
      dev.log(
        '← ${response.statusCode} ${response.requestOptions.uri}',
        name: 'HTTP',
      );
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enabled) {
      dev.log(
        '✗ ${err.response?.statusCode} ${err.requestOptions.uri}',
        name: 'HTTP',
      );
    }
    super.onError(err, handler);
  }
}
