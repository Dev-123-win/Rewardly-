import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;
  InterstitialAd? _interstitialAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;
  NativeAd? _nativeAd;

  bool _isRewardedAdLoading = false;
  bool _isAppOpenAdLoading = false;
  bool _isInterstitialAdLoading = false;
  bool _isRewardedInterstitialAdLoading = false;

  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test ID
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String appOpenAdUnitId = 'ca-app-pub-3940256099942544/3419835294'; // Test ID
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static const String rewardedInterstitialAdUnitId = 'ca-app-pub-3940256099942544/5354046379'; // Test ID
  static const String nativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110'; // Test ID

  void loadRewardedAd() {
    if (_isRewardedAdLoading) return;
    _isRewardedAdLoading = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          _isRewardedAdLoading = false;
        },
      ),
    );
  }

  void showRewardedAd({
    required Function(RewardItem) onUserEarnedReward,
    required Function onAdDismissed,
  }) {
    if (_rewardedAd == null) {
      loadRewardedAd();
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        onAdDismissed();
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        loadRewardedAd();
      },
    );
    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        onUserEarnedReward(reward);
      },
    );
    _rewardedAd = null;
  }

  void loadAppOpenAd() {
    if (_isAppOpenAdLoading) return;
    _isAppOpenAdLoading = true;

    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          _appOpenAd = null;
          _isAppOpenAdLoading = false;
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
        ad.dispose();
        loadAppOpenAd();
      },
    );
    _appOpenAd!.show();
    _appOpenAd = null;
  }

  void loadInterstitialAd() {
    if (_isInterstitialAdLoading) return;
    _isInterstitialAdLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoading = false;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          _isInterstitialAdLoading = false;
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
        ad.dispose();
        loadInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void loadRewardedInterstitialAd() {
    if (_isRewardedInterstitialAdLoading) return;
    _isRewardedInterstitialAdLoading = true;

    RewardedInterstitialAd.load(
      adUnitId: rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedInterstitialAd = ad;
          _isRewardedInterstitialAdLoading = false;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedInterstitialAd = null;
          _isRewardedInterstitialAdLoading = false;
        },
      ),
    );
  }

  void showRewardedInterstitialAd({
    required Function(RewardItem) onUserEarnedReward,
    required Function onAdDismissed,
  }) {
    if (_rewardedInterstitialAd == null) {
      loadRewardedInterstitialAd();
      return;
    }
    _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        onAdDismissed();
        loadRewardedInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadRewardedInterstitialAd();
      },
    );
    _rewardedInterstitialAd!.show(
      onUserEarnedReward: (ad, reward) {
        onUserEarnedReward(reward);
      },
    );
    _rewardedInterstitialAd = null;
  }
  
  void loadNativeAd(NativeAdListener listener) {
    _nativeAd = NativeAd(
      adUnitId: nativeAdUnitId,
      listener: listener,
      request: const AdRequest(),
    )..load();
  }

  void disposeNativeAd() {
    _nativeAd?.dispose();
    _nativeAd = null;
  }
}
