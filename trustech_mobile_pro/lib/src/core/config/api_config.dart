class ApiConfig {
  // Local network backend (uvicorn on the dev host). Swap back to the hosted
  // URL for staging/prod.
  static const String baseUrl = "http://10.216.91.251:8000/api/v1";

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 20);
}
