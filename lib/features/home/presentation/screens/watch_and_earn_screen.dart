
import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rewardly/app/app_theme.dart';
import 'package:rewardly/shared/services/local_ad_service.dart';
import 'package:rewardly/shared/services/remote_config_service.dart';

import '../../../../app/providers/user_data_provider.dart';
import '../../../../shared/services/ad_service.dart';

class WatchAndEarnScreen extends StatefulWidget {
  const WatchAndEarnScreen({super.key});

  @override
  State<WatchAndEarnScreen> createState() => _WatchAndEarnScreenState();
}

class _WatchAndEarnScreenState extends State<WatchAndEarnScreen>
    with WidgetsBindingObserver {
  // --- Services ---
  late final RemoteConfigService _remoteConfigService;
  late final LocalAdService _localAdService;
  final AdService _adService = AdService();

  // --- Remote Config Values (with defaults) ---
  int _adReward = 15;
  int _adsPerDayLimit = 10;
  Duration _adCooldown = const Duration(seconds: 30);

  // --- Local State ---
  int _sessionPoints = 0;
  int _adsWatchedToday = 0;

  // --- UI and Ad Loading State ---
  bool _isLoading = true; // For initial setup
  bool _isAdLoading = false;
  bool _adFailedToLoad = false;
  bool _showSuccessAnimation = false;

  // --- Cooldown Timer State ---
  Timer? _cooldownTimer;
  Duration _remainingCooldown = Duration.zero;
  bool _isCooldownPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  /// Initializes services, fetches config, and loads the first ad.
  Future<void> _initialize() async {
    _remoteConfigService = await RemoteConfigService.getInstance();
    _localAdService = await LocalAdService.getInstance();

    if (mounted) {
      setState(() {
        _adReward = _remoteConfigService.adReward;
        _adsPerDayLimit = _remoteConfigService.adsPerDayLimit;
        _adCooldown = _remoteConfigService.adCooldown;
        _adsWatchedToday = _localAdService.getAdsWatchedToday();
        _isLoading = false;
      });
    }

    await _loadAdWithRetries();
  }

  @override
  void dispose() {
    _saveSessionPointsToFirestore();
    WidgetsBinding.instance.removeObserver(this);
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_cooldownTimer?.isActive ?? false) {
        _isCooldownPaused = true;
        _cooldownTimer?.cancel();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isCooldownPaused) {
        _isCooldownPaused = false;
        _startCooldownTimer();
      }
    }
  }

  void _saveSessionPointsToFirestore() {
    if (_sessionPoints <= 0) return;

    final user = Provider.of<UserDataProvider>(context, listen: false).user;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    userRef.update({
      'points': FieldValue.increment(_sessionPoints),
    }).catchError((error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace,
          reason: 'Failed to save session points to Firestore');
    });
  }

  Future<void> _loadAdWithRetries({int maxRetries = 3}) async {
    if (_isAdLoading) return;
    setState(() => _isAdLoading = true);

    for (int i = 0; i < maxRetries; i++) {
      try {
        await _adService.loadRewardedAd();
        if (mounted) setState(() => _isAdLoading = false);
        return;
      } catch (e) {
        if (i < maxRetries - 1) {
          await Future.delayed(Duration(seconds: pow(2, i).toInt()));
        }
      }
    }

    if (mounted) {
      setState(() => _isAdLoading = false);
    }
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingCooldown.inSeconds > 0) {
        if (mounted) {
          setState(() {
            _remainingCooldown = _remainingCooldown - const Duration(seconds: 1);
          });
        }
      } else {
        timer.cancel();
        if (mounted) setState(() {});
      }
    });
  }

  void _claimReward() {
    _sessionPoints += _adReward;
    _localAdService.incrementAdWatchCount();

    Provider.of<UserDataProvider>(context, listen: false).incrementPoints(_adReward);
    setState(() {
      _adsWatchedToday = _localAdService.getAdsWatchedToday();
      _showSuccessAnimation = true;
    });

    _remainingCooldown = _adCooldown;
    _startCooldownTimer();

    _loadAdWithRetries();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You earned $_adReward points!')),
    );
  }

  void _showAdAndClaimReward() {
    if (_adService.isAdReady) {
      _adService.showRewardedAd(
        onAdRewarded: _claimReward,
        onAdFailed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ad failed to show. Please try again.')),
          );
          _loadAdWithRetries();
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad not ready, please wait.')),
      );
      if (!_isAdLoading) _loadAdWithRetries();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch & Earn'),
        actions: [
          // Temporary button to toggle theme
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBackground(theme),
          if (_showSuccessAnimation) _buildSuccessAnimation(),
          _buildContent(context, theme),
        ],
      ),
    );
  }

  Widget _buildBackground(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return Center(
      child: Lottie.asset(
        'assets/animations/success.json',
        width: 250,
        height: 250,
        repeat: false,
        onLoaded: (composition) {
          Future.delayed(
              composition.duration - const Duration(milliseconds: 500), () {
            if (mounted) setState(() => _showSuccessAnimation = false);
          });
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    return Consumer<UserDataProvider>(
      builder: (context, userDataProvider, child) {
        if (_isLoading || userDataProvider.user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = userDataProvider.user!;
        bool isAdLimitReached = _adsWatchedToday >= _adsPerDayLimit;
        bool isCooldownActive = _remainingCooldown.inSeconds > 0;
        bool canWatchAd = !isAdLimitReached &&
            !isCooldownActive &&
            _adService.isAdReady &&
            !_isAdLoading;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildPointsDisplay(user, theme),
                    const SizedBox(height: 20),
                    _buildAdWatchStatus(theme),
                    const SizedBox(height: 30),
                    _buildWatchButton(canWatchAd, isAdLimitReached, isCooldownActive),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPointsDisplay(dynamic user, ThemeData theme) {
    return Column(
      children: [
        Text(
          'Your Points',
          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Text(
          '${user.points}',
          style: theme.textTheme.displayMedium?.copyWith(color: theme.colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildAdWatchStatus(ThemeData theme) {
    return Text(
      'Ads Watched Today: $_adsWatchedToday / $_adsPerDayLimit',
      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }

  Widget _buildWatchButton(bool canWatchAd, bool isAdLimitReached, bool isCooldownActive) {
    return ElevatedButton.icon(
      onPressed: canWatchAd ? _showAdAndClaimReward : null,
      icon: _isAdLoading
          ? const SizedBox.shrink()
          : const Icon(Icons.movie_creation_outlined),
      label: _buildButtonChild(isAdLimitReached, isCooldownActive),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 56),
      ),
    );
  }

  Widget _buildButtonChild(bool isAdLimitReached, bool isCooldownActive) {
    if (_isAdLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset('assets/animations/loading.json', height: 24),
          const SizedBox(width: 12),
          const Text('LOADING AD'),
        ],
      );
    }
    if (_adFailedToLoad) {
      return const Text('TRY AGAIN');
    }
    if (isAdLimitReached) {
      return const Text('LIMIT REACHED');
    }
    if (isCooldownActive) {
      return Text('NEXT AD IN ${_remainingCooldown.inSeconds}S');
    }
    return const Text('WATCH & EARN');
  }
}
