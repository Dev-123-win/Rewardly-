import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewardly/providers/user_data_provider.dart';
import 'package:rewardly/services/ad_service.dart';
import 'package:rewardly/models/user_tier.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:developer' as developer;

import 'package:rewardly/widgets/main_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    adService.loadRewardedAd();
    adService.loadRewardedInterstitialAd();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          developer.log('BannerAd failed to load: $err', name: 'HomeScreen');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewardly'),
      ),
      drawer: const MainDrawer(),
      body: Consumer<UserDataProvider>(
        builder: (context, userDataProvider, child) {
          if (userDataProvider.isLoading && userDataProvider.userData == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userDataProvider.userData == null) {
            return const Center(child: Text("Could not load user data."));
          }
          return _buildContent(context, theme, userDataProvider);
        },
      ),
      bottomNavigationBar: _isBannerAdReady
          ? SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildContent(
      BuildContext context, ThemeData theme, UserDataProvider userDataProvider) {
    final points = userDataProvider.points;
    final userTier = UserTier.values[userDataProvider.userData!['tier'] ?? 0];
    final adsWatched = userDataProvider.userData!['adsWatchedToday'] ?? 0;
    final dailyStreak = userDataProvider.userData!['dailyStreak'] ?? 0;

    return RefreshIndicator(
      onRefresh: () {
        return Provider.of<UserDataProvider>(context, listen: false).fetchUserData();
      },
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildPointsCard(theme, points, userTier),
          const SizedBox(height: 20),
          _buildTierProgress(theme, points, userTier),
          const SizedBox(height: 20),
          _buildDailyTasks(theme, adsWatched, dailyStreak),
          const SizedBox(height: 20),
          _buildActionGrid(context, theme),
        ],
      ),
    );
  }

  void _showRewardAd(bool isGame) {
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

    final adFunction = isGame
        ? adService.showRewardedInterstitialAd
        : adService.showRewardedAd;

    adFunction(
      onUserEarnedReward: (reward) async {
        final result = await userDataProvider.handleReward(reward.amount.toInt(), isGameReward: isGame);
        if (mounted && result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You earned ${reward.amount} points!')),
          );
        } else if (mounted && !result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to claim reward: ${result['message']}')),
          );
        }
      },
      onAdDismissed: () {
        // Preload the next ad
        if (isGame) {
          adService.loadRewardedInterstitialAd();
        } else {
          adService.loadRewardedAd();
        }
      },
    );
  }

  Widget _buildPointsCard(ThemeData theme, int points, UserTier userTier) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [userTier.color, userTier.color.withAlpha(178)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Points',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              points.toString(),
              style: theme.textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierProgress(ThemeData theme, int points, UserTier userTier) {
    // Tier logic is now handled in UserDataProvider
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tier Progress', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text('You are currently at the ${userTier.name} tier.'),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTasks(ThemeData theme, int adsWatched, int dailyStreak) {
    return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Tasks', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 10),
                Text('Ads Watched Today: $adsWatched/10'),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: adsWatched / 10,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
                const SizedBox(height: 10),
                Text('Daily Streak: $dailyStreak days'),
              ],
            )));
  }

  Widget _buildActionGrid(BuildContext context, ThemeData theme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildActionButton(
          context,
          theme,
          icon: Icons.slow_motion_video,
          label: 'Watch & Earn',
          onTap: () => _showRewardAd(false),
        ),
        _buildActionButton(
          context,
          theme,
          icon: Icons.videogame_asset,
          label: 'Play & Earn',
          onTap: () => _showRewardAd(true),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, ThemeData theme, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: theme.primaryColor),
                const SizedBox(height: 10),
                Text(label, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
              ],
            )
        )
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
