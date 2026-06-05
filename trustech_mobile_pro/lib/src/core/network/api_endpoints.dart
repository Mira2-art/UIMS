/// Relative API paths, mirroring the Trustech backend (`/api/v1`).
/// Joined onto [ApiConfig.baseUrl] by Dio.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String auth = "/auth";
  static const String signin = "$auth/login";
  static const String signup = "$auth/register";
  static const String refresh = "$auth/refresh";
  static const String logout = "$auth/logout";

  static const String forgotPassword = "$auth/forgot-password";
  static const String resetPassword = "$auth/reset-password";
  static const String changePassword = "$auth/change-password";

  static const String sendVerification = "$auth/send-verification";
  static const String verifyEmail = "$auth/verify-email";

  // ── Current user ──────────────────────────────────────────────────────────
  static const String me = "/users/me";

  /// Endpoints that must NOT carry an Authorization header / trigger refresh.
  static const Set<String> publicAuthPaths = {
    signin,
    signup,
    refresh,
    forgotPassword,
    resetPassword,
    verifyEmail,
  };
}
