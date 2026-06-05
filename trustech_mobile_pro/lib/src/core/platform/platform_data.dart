class PlatformData {
  final String deviceId;
  final String deviceName;
  final String platform;
  final String osVersion;
  final String appVersion;

  const PlatformData({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.osVersion,
    required this.appVersion,
  });

  factory PlatformData.empty() {
    return const PlatformData(
      deviceId: '',
      deviceName: '',
      platform: 'unknown',
      osVersion: '',
      appVersion: '',
    );
  }

  Map<String, dynamic> toDeviceInfoJson() {
    return {"device_info": toFlatJson()};
  }

  Map<String, dynamic> toFlatJson() {
    return {
      "device_id": deviceId,
      "device_name": deviceName,
      "platform": platform,
      "os_version": osVersion,
      "app_version": appVersion,
    };
  }
}
