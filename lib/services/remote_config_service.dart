import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:developer';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await _remoteConfig.setDefaults(const {
        'app_bar_title': 'Rewardly',
      });
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      log('Error initializing Remote Config: $e', name: 'RemoteConfigService');
    }
  }

  String getString(String key) {
    return _remoteConfig.getString(key);
  }
}
