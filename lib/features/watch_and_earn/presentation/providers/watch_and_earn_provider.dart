import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../data/services/ad_manager.dart';
import '../../data/services/firestore_service.dart';

class WatchAndEarnProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _points = 0;
  int _dailyAdCount = 0;
  Timestamp _lastAdWatchedTimestamp = Timestamp.fromMillisecondsSinceEpoch(0);
  RewardedAd? _rewardedAd;
  bool _isAdReady = false;
  bool _isAdLimitReached = false;
  bool _isTimeLimitActive = false;

  int get points => _points;
  int get dailyAdCount => _dailyAdCount;
  bool get isAdReady => _isAdReady;
  bool get isAdLimitReached => _isAdLimitReached;
  bool get isTimeLimitActive => _isTimeLimitActive;

  WatchAndEarnProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final user = _auth.currentUser;
    if (user != null) {
      final data = await _firestoreService.getWatchAndEarnData(user.uid);
      if (data != null) {
        _points = data['points'] ?? 0;
        _dailyAdCount = data['dailyAdCount'] ?? 0;
        _lastAdWatchedTimestamp = data['lastAdWatchedTimestamp'] ?? Timestamp.fromMillisecondsSinceEpoch(0);
      }
      _checkLimits();
      loadAd();
      notifyListeners();
    }
  }

  void _checkLimits() {
    final now = Timestamp.now();
    final lastAdTime = _lastAdWatchedTimestamp.toDate();
    final difference = now.toDate().difference(lastAdTime);

    _isAdLimitReached = _dailyAdCount >= 10;
    _isTimeLimitActive = difference.inMinutes < 5;

    if (now.toDate().day != lastAdTime.day) {
      _dailyAdCount = 0;
      _isAdLimitReached = false;
    }
  }

  void loadAd() {
    if (_isAdLimitReached || _isTimeLimitActive) return;

    AdManager.loadRewardedAd(
      onAdLoaded: (ad) {
        _rewardedAd = ad;
        _isAdReady = true;
        notifyListeners();

        _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            _isAdReady = false;
            ad.dispose();
            loadAd();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            _isAdReady = false;
            ad.dispose();
            loadAd();
          },
        );
      },
      onAdFailedToLoad: (error) {
        _isAdReady = false;
        notifyListeners();
      },
    );
  }

  void showAd() {
    if (_isAdReady && _rewardedAd != null) {
      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        _onUserEarnedReward(reward.amount.toInt());
      });
    }
  }

  Future<void> _onUserEarnedReward(int amount) async {
    final user = _auth.currentUser;
    if (user != null) {
      _points += amount;
      _dailyAdCount++;
      _lastAdWatchedTimestamp = Timestamp.now();

      await _firestoreService.updateUserWatchAndEarnData(
        user.uid,
        _points,
        _dailyAdCount,
        _lastAdWatchedTimestamp,
      );
      _checkLimits();
      notifyListeners();
    }
  }
}
