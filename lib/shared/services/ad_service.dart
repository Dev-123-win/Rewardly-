import 'dart:async';
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Use test ad units for development to avoid policy violations.
  // Replace with your real ad unit ID for production.
  static final String rewardedAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917' // Android Test ID
      : 'ca-app-pub-3940256099942544/1712485313'; // iOS Test ID

  // Your real AdMob Rewarded Ad Unit ID
  // static final String rewardedAdUnitId = 'ca-app-pub-3863562453957252/781943874';

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  bool get isAdReady => _isAdLoaded;

  /// Loads a rewarded ad.
  Future<void> loadRewardedAd() {
    final completer = Completer<void>();
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
          completer.complete();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isAdLoaded = false;
          completer.completeError(error);
        },
      ),
    );
    return completer.future;
  }

  /// Shows the rewarded ad if it's loaded.
  void showRewardedAd({required Function onAdRewarded, Function? onAdFailed}) {
    if (!_isAdLoaded || _rewardedAd == null) {
      onAdFailed?.call();
      loadRewardedAd().catchError((_){
        // Silently handle error, maybe log it.
      });
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        loadRewardedAd().catchError((_){
          // Silently handle error
        });
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        onAdFailed?.call();
        loadRewardedAd().catchError((_){
          // Silently handle error
        });
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        onAdRewarded();
      },
    );
    _rewardedAd = null;
    _isAdLoaded = false;
  }
}
