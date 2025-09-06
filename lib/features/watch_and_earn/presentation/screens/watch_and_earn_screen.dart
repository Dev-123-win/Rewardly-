import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../../app/providers/user_data_provider.dart';
import '../../../../shared/services/ad_service.dart';

class WatchAndEarnScreen extends StatefulWidget {
  const WatchAndEarnScreen({super.key});

  @override
  State<WatchAndEarnScreen> createState() => _WatchAndEarnScreenState();
}

class _WatchAndEarnScreenState extends State<WatchAndEarnScreen> {
  static const int adReward = 15;
  static const int adsPerDayLimit = 10;
  static const Duration adCooldown = Duration(seconds: 30);

  final AdService _adService = AdService();

  bool _showSuccessAnimation = false;
  Timer? _cooldownTimer;
  Duration _remainingCooldown = Duration.zero;

  @override
  void initState() {
    super.initState();
    _adService.loadRewardedAd();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown(DateTime lastAdTime) {
    _cooldownTimer?.cancel();
    final nextAdTime = lastAdTime.add(adCooldown);
    final now = DateTime.now();

    if (now.isBefore(nextAdTime)) {
      _remainingCooldown = nextAdTime.difference(now);
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingCooldown.inSeconds > 0) {
          setState(() {
            _remainingCooldown = _remainingCooldown - const Duration(seconds: 1);
          });
        } else {
          timer.cancel();
          setState(() {}); // Trigger rebuild to re-enable button
        }
      });
    }
  }

  void _showAdAndClaimReward(UserModel user) {
    _adService.showRewardedAd(
      onAdRewarded: () {
        _claimAdReward(user);
      },
      onAdFailed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load ad. Please try again.')),
        );
      },
    );
  }

  Future<void> _claimAdReward(UserModel user) async {
    final now = DateTime.now();
    final batch = FirebaseFirestore.instance.batch();
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    batch.update(userRef, {
      'points': FieldValue.increment(adReward),
      'lastAdWatchedTimestamp': Timestamp.fromDate(now),
      'adsWatchedToday': FieldValue.increment(1),
    });

    try {
      await batch.commit();

      if (mounted) {
        _startCooldown(now);
        setState(() {
          _showSuccessAnimation = true;
        });
        Timer(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showSuccessAnimation = false;
            });
          }
        });
      }
    } catch (e) {
      // Handle potential commit errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch & Earn'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<UserDataProvider>(
        builder: (context, userDataProvider, child) {
          final user = userDataProvider.user;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          bool isAdLimitReached = user.adsWatchedToday >= adsPerDayLimit;
          bool isCooldownActive = _remainingCooldown.inSeconds > 0;

          return Stack(
            children: [
              Lottie.asset(
                'assets/animations/coin.json',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              if (_showSuccessAnimation)
                Center(
                  child: Lottie.asset(
                    'assets/animations/success.json',
                    width: 200,
                    height: 200,
                    repeat: false,
                  ),
                ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Total Points',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    Text(
                      '${user.points}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Ads Watched Today: ${user.adsWatchedToday} / $adsPerDayLimit',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: (isAdLimitReached || isCooldownActive || !_adService.isAdReady)
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              _showAdAndClaimReward(user);
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _buildButtonChild(isAdLimitReached, isCooldownActive),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildButtonChild(bool isAdLimitReached, bool isCooldownActive) {
    if (!_adService.isAdReady) {
       return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset('assets/animations/loading.json', height: 24),
          const SizedBox(width: 8),
          const Text('Loading Ad...'),
        ],
      );
    }
    if (isAdLimitReached) {
      return const Text('Daily Limit Reached');
    }
    if (isCooldownActive) {
      return Text('Next ad in ${_remainingCooldown.inSeconds}s');
    }
    return const Text('Watch Ad & Earn');
  }
}
