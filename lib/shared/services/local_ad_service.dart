
import 'package:shared_preferences/shared_preferences.dart';

/// A service to manage the daily ad watch count locally on the device.
class LocalAdService {
  static const String _adCountKey = 'daily_ad_count';
  static const String _lastAdDateKey = 'last_ad_date';

  SharedPreferences? _prefs;

  // Private constructor
  LocalAdService._();

  // Singleton instance
  static LocalAdService? _instance;

  // Get or create the singleton instance
  static Future<LocalAdService> getInstance() async {
    if (_instance == null) {
      final service = LocalAdService._();
      await service._init();
      _instance = service;
    }
    return _instance!;
  }

  /// Initializes SharedPreferences and resets the daily count if needed.
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await _resetCountIfNewDay();
  }

  /// Checks if the last ad was watched on a different day and resets the count.
  Future<void> _resetCountIfNewDay() async {
    final lastAdDateStr = _prefs?.getString(_lastAdDateKey);
    if (lastAdDateStr == null) {
      return; // No ads watched yet, nothing to reset
    }

    final lastAdDate = DateTime.tryParse(lastAdDateStr);
    if (lastAdDate == null) return;

    final now = DateTime.now();
    final isSameDay = now.year == lastAdDate.year &&
        now.month == lastAdDate.month &&
        now.day == lastAdDate.day;

    if (!isSameDay) {
      await _prefs?.setInt(_adCountKey, 0);
    }
  }

  /// Gets the number of ads watched today.
  int getAdsWatchedToday() {
    return _prefs?.getInt(_adCountKey) ?? 0;
  }

  /// Increments the ad watch count for today.
  Future<void> incrementAdWatchCount() async {
    final currentCount = getAdsWatchedToday();
    await _prefs?.setInt(_adCountKey, currentCount + 1);
    await _prefs?.setString(_lastAdDateKey, DateTime.now().toIso8601String());
  }
}
