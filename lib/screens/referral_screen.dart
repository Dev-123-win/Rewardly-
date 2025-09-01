import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rewardly/widgets/rewardly_app_bar.dart';
import 'package:flutter/services.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const RewardlyAppBar(title: 'Refer a Friend'),
      body: user == null
          ? _buildLoggedOutView(context, theme)
          : _buildReferralView(context, theme, user),
    );
  }

  Widget _buildLoggedOutView(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_add_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'Log in to get your referral code',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralView(BuildContext context, ThemeData theme, User user) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final referralCode = userData?['referralCode'] as String? ?? 'Generating...';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 32),
              _buildReferralCodeCard(context, theme, referralCode),
              const SizedBox(height: 32),
              _buildHowItWorks(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Icon(
          Icons.card_giftcard,
          size: 60,
          color: theme.primaryColor,
        ),
        const SizedBox(height: 16),
        Text(
          'Invite Friends, Get Rewards!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Share your unique code with friends. When they sign up, you both get bonus points!',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildReferralCodeCard(BuildContext context, ThemeData theme, String referralCode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Unique Referral Code',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 4,
          shadowColor: theme.primaryColor.withAlpha(75),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: referralCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Referral code copied to clipboard!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    referralCode,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                      letterSpacing: 2,
                    ),
                  ),
                  Icon(
                    Icons.copy_all_outlined,
                    color: theme.primaryColor,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorks(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How It Works',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildStep(theme, Icons.share_outlined, 'Share Your Code', 'Send your code to your friends.'),
        const SizedBox(height: 12),
        _buildStep(theme, Icons.person_add_alt_1_outlined, 'Friend Signs Up', 'Your friend creates an account using your code.'),
        const SizedBox(height: 12),
        _buildStep(theme, Icons.military_tech_outlined, 'You Both Get Rewarded', 'You and your friend receive bonus points!'),
      ],
    );
  }

  Widget _buildStep(ThemeData theme, IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 32, color: theme.colorScheme.secondary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
