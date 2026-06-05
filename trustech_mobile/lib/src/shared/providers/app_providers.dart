/// Barrel for app-wide shared providers — a single import surface for the
/// cross-cutting providers a feature typically needs.
///
/// Device metadata for the auth contract (`client_id` + `device_info`) is
/// produced by the platform layer: use [platformDataProvider] for the typed
/// model or [deviceInfoJsonProvider] for the ready-to-send `{"device_info": {...}}`
/// body. Feature-specific providers live under `features/<name>/providers/`.
library;

// Configuration & environment
export '../../core/config/env_config.dart' show Env, envProvider;

// Localization & theme
export '../../core/locales/locale_provider.dart' show localeProvider;
export '../../core/theme/theme_provider.dart'
    show themeProvider, sharedPreferencesProvider;

// Platform & device metadata
export '../../core/platform/platform_info.dart' show platformInfoProvider;
export '../../core/platform/platform_data.dart' show PlatformData;
export '../../core/platform/platform_data_provider.dart'
    show platformDataProvider, deviceInfoJsonProvider, deviceHttpHeadersProvider;

// Networking & storage
export '../../core/network/client/dio_provider.dart' show dioProvider;
export '../../core/storage/token_provider.dart' show TokenProvider;
export '../../core/storage/secure_storage.dart' show tokenStoreProvider;
