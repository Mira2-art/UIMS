import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/api_config.dart';
import '../../config/env_config.dart';
import '../../storage/secure_storage.dart';
import 'logging_interceptor.dart';
import 'token_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final tokenStore = ref.watch(tokenStoreProvider);
  final env = ref.watch(envProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.addAll([
    TokenInterceptor(tokenStore, env.clientId),
    LoggingInterceptor(enabled: true),
  ]);

  return dio;
});
