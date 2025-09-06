
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;

  // Private constructor for the singleton pattern
  RemoteConfigService._(this._remoteConfig);

  static RemoteConfigService? _instance;

  /// Gets the singleton instance of the RemoteConfigService.
  ///
  /// This method initializes the service, sets default values, and fetches
  /// the latest configuration from the Firebase backend.
  static Future<RemoteConfigService> getInstance() async {
    if (_instance == null) {
      final remoteConfig = FirebaseRemoteConfig.instance;

      // Set fetch settings
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1), // Fetch new config at most once per hour
      ));

      // Set default values in case the fetch fails
      await remoteConfig.setDefaults(const {
        'ad_reward': 15,
        'ads_per_day_limit': 10,
        'ad_cooldown_seconds': 30,
      });

      // Fetch and activate the configuration
      await remoteConfig.fetchAndActivate();

      _instance = RemoteConfigService._(remoteConfig);
    }
    return _instance!;
  }

  // --- Getters for remote config values ---

  /// The number of points to award for watching a rewarded ad.
  int get adReward => _remoteConfig.getInt('ad_reward');

  /// The maximum number of rewarded ads a user can watch per day.
  int get adsPerDayLimit => _remoteConfig.getInt('ads_per_day_limit');

  /// The cooldown duration a user must wait before watching another ad.
  Duration get adCooldown => Duration(seconds: _remoteConfig.getInt('ad_cooldown_seconds'));
}
