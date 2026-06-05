import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'platform_data.dart';

final deviceInfoPluginProvider = Provider<DeviceInfoPlugin>((ref) {
  return DeviceInfoPlugin();
});

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

final platformDataProvider = FutureProvider<PlatformData>((ref) async {
  final deviceInfo = ref.watch(deviceInfoPluginProvider);
  final pkg = await ref.watch(packageInfoProvider.future);

  final appVersion = pkg.version;

  if (kIsWeb) {
    final web = await deviceInfo.webBrowserInfo;
    return PlatformData(
      deviceId: web.userAgent ?? "unknown",
      deviceName: web.browserName.name,
      platform: "android",
      osVersion: web.platform ?? "unknown",
      appVersion: appVersion,
    );
  }

  if (Platform.isIOS) {
    final ios = await deviceInfo.iosInfo;
    return PlatformData(
      deviceId: ios.identifierForVendor ?? "unknown",
      deviceName: ios.name,
      platform: "ios",
      osVersion: ios.systemVersion,
      appVersion: appVersion,
    );
  }

  if (Platform.isAndroid) {
    final android = await deviceInfo.androidInfo;
    return PlatformData(
      deviceId: android.id,
      deviceName: android.model,
      platform: "android",
      osVersion: android.version.release,
      appVersion: appVersion,
    );
  }

  return PlatformData(
    deviceId: "desktop-id-unknown",
    deviceName: "desktop",
    platform: Platform.operatingSystem,
    osVersion: Platform.operatingSystemVersion,
    appVersion: appVersion,
  );
});

final deviceInfoJsonProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final data = await ref.watch(platformDataProvider.future);
  return data.toDeviceInfoJson();
});

final deviceHttpHeadersProvider = FutureProvider<Map<String, String>>((ref) async {
  final data = await ref.watch(platformDataProvider.future);
  return {
    "x-device-id": data.deviceId,
    "x-platform": data.platform,
    "x-app-version": data.appVersion,
  };
});
