import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:rewardly/models/user_tier.dart';
import 'package:rewardly/providers/user_data_provider.dart';
import 'package:rewardly/services/ad_service.dart';
import 'package:rewardly/widgets/points_card.dart';
import 'package:rewardly/widgets/rewardly_app_bar.dart';
import 'package:rewardly/widgets/streak_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AdService _adService = AdService();
  bool _isAdShowing = false;
  bool _isHintAdShowing = false;
  bool _isAdmin = false;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _adService.loadRewardedAd();
    _adService.loadRewardedInterstitialAd();
    _checkAdminStatus();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {});
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final idTokenResult = await user.getIdTokenResult();
      if (mounted) {
        setState(() {
          _isAdmin = idTokenResult.claims?['admin'] == true;
        });
      }
    }
  }

  Future<void> _handleAdWatched() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userData = await userDocRef.get();
    final data = userData.data() as Map<String, dynamic>;

    final today = DateTime.now();
    final lastAdDate = (data['lastAdWatchedDate'] as Timestamp).toDate();
    final isNewDay = today.difference(lastAdDate).inDays > 0;

    int adsWatchedToday = data['adsWatchedToday'];
    int dailyStreak = data['dailyStreak'];

    if (isNewDay) {
      if (today.difference(lastAdDate).inDays > 1) {
        dailyStreak = 0;
      }
      adsWatchedToday = 0;
    }

    if (adsWatchedToday >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have reached your daily ad limit.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    adsWatchedToday++;
    final pointsToAward = _getPointsForTier(UserTier.values[data['tier']]);

    if (adsWatchedToday == 5) {
      dailyStreak++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Daily goal complete! Your streak is now $dailyStreak days.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    UserTier newTier = UserTier.values[data['tier']];
    if (dailyStreak >= 7 && newTier == UserTier.bronze) {
      newTier = UserTier.silver;
      _showTierPromotionDialog('Silver');
    } else if (dailyStreak >= 30 && newTier == UserTier.silver) {
      newTier = UserTier.gold;
      _showTierPromotionDialog('Gold');
    }

    await userDocRef.update({
      'points': FieldValue.increment(pointsToAward),
      'adsWatchedToday': adsWatchedToday,
      'dailyStreak': dailyStreak,
      'lastAdWatchedDate': Timestamp.now(),
      'tier': newTier.index,
    });
  }

  void _showRewardedAd(UserTier userTier) {
    setState(() {
      _isAdShowing = true;
    });

    _adService.showRewardedAd(
      onUserEarnedReward: (reward) => _handleAdWatched(),
      onAdDismissed: () {
        setState(() {
          _isAdShowing = false;
        });
      },
    );
  }

  void _showRewardedInterstitialAd() {
    setState(() {
      _isHintAdShowing = true;
    });

    _adService.showRewardedInterstitialAd(
      onUserEarnedReward: (reward) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hint: Complete your profile to earn extra points!'),
            duration: Duration(seconds: 5),
          ),
        );
      },
      onAdDismissed: () {
        setState(() {
          _isHintAdShowing = false;
        });
      },
    );
  }

  void _showTierPromotionDialog(String tierName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content: Text('You have been promoted to the $tierName tier!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  int _getPointsForTier(UserTier tier) {
    switch (tier) {
      case UserTier.gold:
        return 60;
      case UserTier.silver:
        return 54;
      case UserTier.bronze:
        return 48;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const RewardlyAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<UserDataProvider>(
            builder: (context, userDataProvider, child) {
              final userPoints = userDataProvider.points;
              final userTier = UserTier.values[userDataProvider.userData?['tier'] ?? 0];
              final dailyStreak = userDataProvider.userData?['dailyStreak'] ?? 0;
              final adsWatchedToday = userDataProvider.userData?['adsWatchedToday'] ?? 0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PointsCard(points: userPoints, userTier: userTier),
                  const SizedBox(height: 20),
                  StreakIndicator(dailyStreak: dailyStreak, adsWatchedToday: adsWatchedToday),
                  const SizedBox(height: 30),
                  _buildWatchAdButton(theme, userTier, adsWatchedToday >= 10),
                  const SizedBox(height: 20),
                  _buildGetHintButton(theme),
                  const SizedBox(height: 20),
                  _buildNavigationButtons(context, theme),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _bannerAd != null
          ? SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      )
          : null,
    );
  }

  Widget _buildWatchAdButton(ThemeData theme, UserTier userTier, bool isAdLimitReached) {
    return ElevatedButton.icon(
      onPressed: _isAdShowing || isAdLimitReached
          ? null
          : () => _showRewardedAd(userTier),
      icon: _isAdShowing
          ? const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
      )
          : const Icon(Icons.movie_creation_outlined),
      label: Text(
        isAdLimitReached
            ? 'Daily Limit Reached'
            : _isAdShowing
                ? 'Loading Ad...'
                : 'Watch Ad, Earn Points',
      ),
    );
  }

  Widget _buildGetHintButton(ThemeData theme) {
    return ElevatedButton.icon(
      onPressed: _isHintAdShowing ? null : _showRewardedInterstitialAd,
      icon: _isHintAdShowing
          ? const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
      )
          : const Icon(Icons.lightbulb_outline),
      label: Text(
        _isHintAdShowing ? 'Loading Hint...' : 'Watch Ad for a Hint',
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        _buildNavButton(
          context,
          icon: Icons.history_outlined,
          label: 'Withdrawal History',
          onPressed: () => context.go('/withdrawal_history'),
        ),
        const SizedBox(height: 15),
        _buildNavButton(
          context,
          icon: Icons.group_add_outlined,
          label: 'Refer a Friend',
          onPressed: () => context.go('/referral'),
        ),
        if (_isAdmin)
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: _buildNavButton(
              context,
              icon: Icons.admin_panel_settings_outlined,
              label: 'Admin Panel',
              onPressed: () => context.go('/admin'),
            ),
          ),
      ],
    );
  }

  Widget _buildNavButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 28, color: theme.primaryColor),
              const SizedBox(width: 16),
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
