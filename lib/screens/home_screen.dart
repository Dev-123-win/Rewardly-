import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:rewardly/main.dart';
import 'package:rewardly/models/user_tier.dart';
import 'package:rewardly/providers/user_data_provider.dart';
import 'package:rewardly/services/ad_service.dart';
import 'package:rewardly/widgets/points_card.dart';
import 'package:rewardly/widgets/streak_indicator.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAdShowing = false;
  bool _isHintAdShowing = false;
  bool _isAdmin = false;
  BannerAd? _bannerAd;
  late final WebViewController _webViewController;
  int? _queuedGameCoins;

  @override
  void initState() {
    super.initState();
    adService.loadRewardedAd();
    adService.loadRewardedInterstitialAd();
    _checkAdminStatus();
    _loadBannerAd();
    _initWebViewController();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    // The WebView controller doesn't need explicit disposal with recent versions
    // of the plugin, but it's good practice if you have specific cleanup.
    super.dispose();
  }

  void _initWebViewController() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'Print',
        onMessageReceived: (JavaScriptMessage message) {
          final parts = message.message.split(':');
          if (parts.isEmpty) return;
          final command = parts[0];
          final value = parts.length > 1 ? parts[1] : null;

          if (command == 'gameCoinsCollected') {
            final coins = int.tryParse(value ?? '0') ?? 0;
            if (coins > 0) {
              _handleGameCoinsCollected(coins);
            }
          } else if (command == 'watchAdToContinue') {
            _handleGameAd();
          }
        },
      )
      ..loadFlutterAsset('assets/endless_runner_game/index.html');
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() {}),
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final idTokenResult = await user.getIdTokenResult(true); // Force refresh
      if (mounted) {
        setState(() {
          _isAdmin = idTokenResult.claims?['admin'] == true;
        });
      }
    }
  }

  int _getPointsForCoins(UserTier tier, int coins) {
    double conversionRate;
    switch (tier) {
      case UserTier.gold:
        conversionRate = 1.0;
        break;
      case UserTier.silver:
        conversionRate = 0.75;
        break;
      case UserTier.bronze:
        conversionRate = 0.5;
        break;
    }
    return (coins * conversionRate).floor();
  }

  Future<void> _handleGameCoinsCollected(int coins) async {
    if (_isAdShowing) {
      _queuedGameCoins = coins;
      return;
    }
    if (!mounted) return;

    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final userTier = _getUserTier(userDataProvider.userData);
    final pointsToAward = _getPointsForCoins(userTier, coins);

    if (pointsToAward > 0) {
      await _processReward(pointsToAward, isGameReward: true, gameCoins: coins);
    }
  }

  void _handleGameAd() {
    adService.showRewardedAd(
      onUserEarnedReward: (reward) {
        _webViewController.runJavaScript('revivePlayer()');
      },
      onAdDismissed: _onAdDismissed,
    );
  }

  Future<void> _handleAdWatched() async {
    if (!mounted) return;
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final userTier = _getUserTier(userDataProvider.userData);
    final pointsToAward = _getPointsForTierFromAds(userTier);
    await _processReward(pointsToAward, isGameReward: false);
  }

  Future<void> _processReward(int points, {required bool isGameReward, int? gameCoins}) async {
    if (!mounted) return;
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final result = await userDataProvider.handleReward(points, isGameReward: isGameReward);

    if (mounted) {
      if (result['success']) {
        if (isGameReward) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You converted $gameCoins coins into $points points!'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          );
        } else {
           if (result['dailyGoalCompleted']) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text('Daily goal complete! Your streak is now ${result['newStreak']} days.'),
               ),
             );
           }
        }

        if (result['tierPromoted']) {
          _showTierPromotionDialog(result['newTierName']);
        }
        _checkAchievements(result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'An error occurred while processing your reward.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _onAdDismissed() {
    if (mounted) {
      setState(() {
        _isAdShowing = false;
      });
      if (_queuedGameCoins != null) {
        _handleGameCoinsCollected(_queuedGameCoins!);
        _queuedGameCoins = null;
      }
    }
  }

  void _checkAchievements(Map<String, dynamic> result) {
    if (result['unlockedAchievements'] != null &&
        result['unlockedAchievements'].isNotEmpty) {
      for (var achievement in result['unlockedAchievements']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Achievement Unlocked: ${achievement.title}'),
            backgroundColor: Colors.amber,
          ),
        );
      }
    }
  }

  void _showRewardedAd() {
    setState(() => _isAdShowing = true);
    adService.showRewardedAd(
      onUserEarnedReward: (reward) => _handleAdWatched(),
      onAdDismissed: _onAdDismissed,
    );
  }

  void _showRewardedInterstitialAd() {
    setState(() => _isHintAdShowing = true);
    adService.showRewardedInterstitialAd(
      onUserEarnedReward: (reward) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hint: Complete your profile to earn extra points!')),
        );
      },
      onAdDismissed: () => setState(() => _isHintAdShowing = false),
    );
  }

  void _showTierPromotionDialog(String tierName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content: Text('You have been promoted to the $tierName tier!'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Awesome!')),
        ],
      ),
    );
  }

  int _getPointsForTierFromAds(UserTier tier) {
    switch (tier) {
      case UserTier.gold: return 60;
      case UserTier.silver: return 54;
      case UserTier.bronze: return 48;
    }
  }

  UserTier _getUserTier(Map<String, dynamic>? userData) {
    final tierIndex = userData?['tier'] as int? ?? 0;
    if (tierIndex >= 0 && tierIndex < UserTier.values.length) {
      return UserTier.values[tierIndex];
    }
    return UserTier.bronze;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewardly'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.auto_mode),
            onPressed: () => themeProvider.setSystemTheme(),
            tooltip: 'Set System Theme',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.go('/how-it-works'),
            tooltip: 'How It Works',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<UserDataProvider>(
          builder: (context, userDataProvider, child) {
            if (userDataProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final userPoints = userDataProvider.points;
            final userTier = _getUserTier(userDataProvider.userData);
            final dailyStreak = userDataProvider.userData?['dailyStreak'] ?? 0;
            final adsWatchedToday = userDataProvider.userData?['adsWatchedToday'] ?? 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PointsCard(points: userPoints, userTier: userTier),
                const SizedBox(height: 20),
                StreakIndicator(dailyStreak: dailyStreak, adsWatchedToday: adsWatchedToday),
                const SizedBox(height: 20),
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: WebViewWidget(controller: _webViewController),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildWatchAdButton(userTier, adsWatchedToday >= 10),
                        const SizedBox(height: 20),
                        _buildGetHintButton(),
                        const SizedBox(height: 20),
                        _buildNavigationButtons(context),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
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

  Widget _buildWatchAdButton(UserTier userTier, bool isAdLimitReached) {
    return ElevatedButton.icon(
      onPressed: _isAdShowing || isAdLimitReached ? null : _showRewardedAd,
      icon: _isAdShowing
          ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
          : const Icon(Icons.movie_creation_outlined),
      label: Text(
        isAdLimitReached ? 'Daily Limit Reached' : _isAdShowing ? 'Loading Ad...' : 'Watch Ad, Earn Points',
      ),
    );
  }

  Widget _buildGetHintButton() {
    return ElevatedButton.icon(
      onPressed: _isHintAdShowing ? null : _showRewardedInterstitialAd,
      icon: _isHintAdShowing
          ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
          : const Icon(Icons.lightbulb_outline),
      label: Text(_isHintAdShowing ? 'Loading Hint...' : 'Get a Hint'),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Column(
      children: [
        _buildNavButton(context, icon: Icons.person_outline, label: 'My Profile', onPressed: () => context.go('/profile')),
        const SizedBox(height: 15),
        _buildNavButton(context, icon: Icons.account_balance_wallet_outlined, label: 'Withdraw Points', onPressed: () => context.go('/withdrawal')),
        const SizedBox(height: 15),
        _buildNavButton(context, icon: Icons.history, label: 'Withdrawal History', onPressed: () => context.go('/withdrawal_history')),
        if (_isAdmin)
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: _buildNavButton(context, icon: Icons.admin_panel_settings_outlined, label: 'Admin Panel', onPressed: () => context.go('/admin')),
          ),
      ],
    );
  }

  Widget _buildNavButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 28, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Text(label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 18, color: theme.colorScheme.onSurface.withAlpha(153)),
            ],
          ),
        ),
      ),
    );
  }
}
