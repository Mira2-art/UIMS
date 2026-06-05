import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class PlatformInfo {
  bool get isIOS;
  bool get isAndroid;
  bool get isDesktop;
  bool get isWeb;
}

class PlatformInfoImpl implements PlatformInfo {
  @override
  bool get isIOS => !kIsWeb && Platform.isIOS;

  @override
  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  @override
  bool get isDesktop =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  @override
  bool get isWeb => kIsWeb;
}

final platformInfoProvider = Provider<PlatformInfo>((ref) {
  return PlatformInfoImpl();
});
