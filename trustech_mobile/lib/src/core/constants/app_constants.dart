/// App-wide constants that are not environment-specific.
///
/// The client identifier is intentionally NOT here — it varies per build
/// (web / mobile-student / mobile-staff) and is loaded from `.env` via
/// [Env.clientId]. Keep secrets and per-environment values in `.env`.
class AppConstants {
  AppConstants._();

  static const String appName = 'Trustech';

  /// Default page size for paginated list endpoints.
  static const int defaultPageSize = 20;
}
