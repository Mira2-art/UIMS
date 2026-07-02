class ApiConfig {
  // Hosted backend (DigitalOcean droplet). The API is served under /api/v1;
  // Swagger docs live at http://161.35.65.49:8000/docs.
  static const String baseUrl = "http://161.35.65.49:8000/api/v1";

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 20);
}
