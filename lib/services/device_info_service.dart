
import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  Future<String?> getDeviceId() async {
    try {
      if (kIsWeb) {
        final webBrowserInfo = await _deviceInfoPlugin.webBrowserInfo;
        return webBrowserInfo.vendor! +
            webBrowserInfo.userAgent! +
            webBrowserInfo.hardwareConcurrency.toString();
      } else {
        if (Platform.isAndroid) {
          final androidInfo = await _deviceInfoPlugin.androidInfo;
          return androidInfo.id;
        } else if (Platform.isIOS) {
          final iosInfo = await _deviceInfoPlugin.iosInfo;
          return iosInfo.identifierForVendor;
        }
      }
    } catch (e) {
      log('Error getting device ID: $e');
    }
    return null;
  }
}
