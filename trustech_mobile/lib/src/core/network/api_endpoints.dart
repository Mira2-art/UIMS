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

  static const String studentMe = "/students/me";

  // ── Student data (need the resolved student_id) ─────────────────────────────
  static String studentResults(String id) => "/students/$id/results";
  static String studentStanding(String id) => "/students/$id/standing";
  static String studentCharges(String id) => "/students/$id/charges";
  static String studentPayments(String id) => "/students/$id/payments";
  static String studentScholarships(String id) => "/students/$id/scholarships";
  static String studentTimetable(String id) => "/students/$id/timetable";
  static String studentAttendance(String id) => "/students/$id/attendance";

  // ── Enrollments / courses ───────────────────────────────────────────────────
  static String enrollmentsForStudent(String id) => "/enrollments?student_id=$id";
  static String course(String id) => "/courses/$id";
  static String courseMaterials(String id) => "/courses/$id/materials";

  // ── Communication ───────────────────────────────────────────────────────────
  static const String announcements = "/communication/announcements";
  static String announcement(String id) => "/communication/announcements/$id";
  static const String notifications = "/communication/notifications";
  static String notificationRead(String id) => "/communication/notifications/$id/read";

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
