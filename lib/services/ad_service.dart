import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:developer' as developer;

class AdService {
  // Use test Ad Unit IDs.
  static String get bannerAdUnitId => 'ca-app-pub-3940256099942544/6300978111';
  static String get rewardedAdUnitId => 'ca-app-pub-3940256099942544/5224354917';
  static String get rewardedInterstitialAdUnitId => 'ca-app-pub-3940256099942544/5354046379';
  static String get appOpenAdUnitId => 'ca-app-pub-3940256099942544/3419835294';
  static String get interstitialAdUnitId => 'ca-app-pub-3940256099942544/1033173712';

  RewardedAd? _rewardedAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;
  AppOpenAd? _appOpenAd;
  InterstitialAd? _interstitialAd;

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (err) {
          developer.log('RewardedAd failed to load: $err', name: 'AdService');
          _rewardedAd = null;
        },
      ),
    );
  }

  void loadRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
      adUnitId: rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedInterstitialAd = ad;
        },
        onAdFailedToLoad: (err) {
          developer.log('RewardedInterstitialAd failed to load: $err', name: 'AdService');
          _rewardedInterstitialAd = null;
        },
      ),
    );
  }

  void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          developer.log('AppOpenAd failed to load: $error', name: 'AdService');
          _appOpenAd = null;
        },
      ),
    );
  }

  void showAppOpenAd() {
    if (_appOpenAd == null) {
      loadAppOpenAd();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        developer.log('AppOpenAd failed to show: $error', name: 'AdService');
        ad.dispose();
        loadAppOpenAd();
      },
    );

    _appOpenAd!.show();
    _appOpenAd = null;
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          developer.log('InterstitialAd failed to load: $error', name: 'AdService');
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd == null) {
      loadInterstitialAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        developer.log('InterstitialAd failed to show: $error', name: 'AdService');
        ad.dispose();
        loadInterstitialAd();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void showRewardedAd({
    required Function(RewardItem) onUserEarnedReward,
    required Function onAdDismissed,
  }) {
    if (_rewardedAd == null) {
      loadRewardedAd();
      onAdDismissed();
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewardedAd();
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        developer.log('RewardedAd failed to show: $err', name: 'AdService');
        ad.dispose();
        loadRewardedAd();
        onAdDismissed();
      },
    );
    _rewardedAd!.show(onUserEarnedReward: (ad, reward) => onUserEarnedReward(reward));
    _rewardedAd = null;
  }

  void showRewardedInterstitialAd({
    required Function(RewardItem) onUserEarnedReward,
    required Function onAdDismissed,
  }) {
    if (_rewardedInterstitialAd == null) {
      loadRewardedInterstitialAd();
      onAdDismissed();
      return;
    }
     _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewardedInterstitialAd();
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
         developer.log('RewardedInterstitialAd failed to show: $err', name: 'AdService');
        ad.dispose();
        loadRewardedInterstitialAd();
        onAdDismissed();
      },
    );
    _rewardedInterstitialAd!.show(onUserEarnedReward: (ad, reward) => onUserEarnedReward(reward));
    _rewardedInterstitialAd = null;
  }
}

final adService = AdService();
