import 'package:flutter/material.dart';
import 'package:rewardly/services/ad_service.dart';

class AppLifecycleReactor with WidgetsBindingObserver {
  final AdService appOpenAdManager;

  AppLifecycleReactor({required this.appOpenAdManager});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      appOpenAdManager.showAppOpenAd();
    }
  }
}
