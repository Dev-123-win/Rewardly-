import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:rewardly/services/ad_service.dart';
import 'package:rewardly/widgets/points_card.dart';
import 'package:rewardly/widgets/rewardly_app_bar.dart';
import 'package:rewardly/screens/store_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AdService _adService = AdService();
  bool _isAdShowing = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _adService.loadRewardedAd();
    _checkAdminStatus();
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

  void _showRewardedAd(UserTier userTier) {
    setState(() {
      _isAdShowing = true;
    });

    _adService.showRewardedAd(
      onUserEarnedReward: (reward) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final pointsToAward = _getPointsForTier(userTier);
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'points': FieldValue.increment(pointsToAward),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You earned $pointsToAward points!'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      onAdDismissed: () {
        setState(() {
          _isAdShowing = false;
        });
      },
    );
  }

  int _getPointsForTier(UserTier tier) {
    switch (tier) {
      case UserTier.gold:
        return 20;
      case UserTier.silver:
        return 15;
      case UserTier.bronze:
      default:
        return 10;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: const RewardlyAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (user != null)
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final userData = snapshot.data!.data() as Map<String, dynamic>?;
                    final userPoints = userData?['points'] as int? ?? 0;
                    final userTier = UserTier.values[userData?['tier'] ?? 0];

                    return Column(
                      children: [
                        PointsCard(points: userPoints, userTier: userTier),
                        const SizedBox(height: 30),
                        _buildWatchAdButton(theme, userTier),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 20),
              _buildNavigationButtons(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWatchAdButton(ThemeData theme, UserTier userTier) {
    return ElevatedButton.icon(
      onPressed: _isAdShowing ? null : () => _showRewardedAd(userTier),
      icon: _isAdShowing
          ? const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
      )
          : const Icon(Icons.movie_creation_outlined),
      label: Text(
        _isAdShowing ? 'Loading Ad...' : 'Watch Ad, Earn Points',
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        _buildNavButton(
          context,
          icon: Icons.store_outlined,
          label: 'Go to Store',
          onPressed: () => context.go('/store'),
        ),
        const SizedBox(height: 15),
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
}
