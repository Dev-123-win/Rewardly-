import 'package:flutter/material.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How It Works'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Welcome to Rewardly!'),
            _buildSectionContent(
              context,
              'Rewardly is a fun and easy way to earn rewards by watching ads and playing games. Here\'s how you can get started:',
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Earning Points'),
            _buildPointItem(
              context,
              icon: Icons.movie_creation_outlined,
              title: 'Watch Ads',
              description: 'Earn points by watching short video ads. You can watch up to 10 ads per day.',
            ),
            _buildPointItem(
              context,
              icon: Icons.games_outlined,
              title: 'Play Our Game',
              description: 'Play our endless runner game and collect coins. These coins can be converted into points.',
            ),
            _buildPointItem(
              context,
              icon: Icons.group_add_outlined,
              title: 'Refer Friends',
              description: 'Invite your friends to join Rewardly and earn bonus points when they sign up.',
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Daily Streaks & Goals'),
            _buildPointItem(
              context,
              icon: Icons.local_fire_department,
              title: 'Complete Daily Goals',
              description: 'Watch 5 ads in a single day to complete your daily goal and increase your streak.',
            ),
            _buildPointItem(
              context,
              icon: Icons.shield_outlined,
              title: 'Climb the Tiers',
              description: 'Maintain your daily streak to get promoted to higher tiers (Bronze, Silver, Gold) and earn more points per ad.',
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Redeeming Rewards'),
            _buildSectionContent(
              context,
              'Once you have collected enough points, you can redeem them for real rewards! Visit the \'Withdrawal\' section to see the available options.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildSectionContent(BuildContext context, String content) {
    return Text(
      content,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  Widget _buildPointItem(BuildContext context, {required IconData icon, required String title, required String description}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
