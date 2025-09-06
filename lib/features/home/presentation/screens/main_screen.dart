
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rewardly/app/models/app_user.dart';
import 'package:rewardly/app/providers/user_data_provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserDataProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboard(context, user),
    );
  }

  Widget _buildDashboard(BuildContext context, AppUser user) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildWelcomeHeader(context, user),
        const SizedBox(height: 24),
        _buildStatsCard(context, user),
        const SizedBox(height: 24),
        _buildFeatureCards(context),
      ],
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, AppUser user) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          user.email.split('@')[0],
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildStatsCard(BuildContext context, AppUser user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, 'Points', user.points.toString(), Icons.star_rounded),
            _buildStatItem(context, 'Streak', '${user.streak} days', Icons.local_fire_department_rounded),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.secondary, size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildFeatureCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          'Earn Rewards',
           style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          context,
          title: 'Watch & Earn',
          subtitle: 'Watch ads to earn points.',
          icon: Icons.movie_creation_outlined,
          onTap: () => context.go('/watch-and-earn'),
          color: Colors.orange,
          animationAsset: 'assets/animations/watch_and_earn.json',
        ).animate().slideX(begin: -0.5, duration: 500.ms, curve: Curves.easeOut),
        const SizedBox(height: 16),
        _buildFeatureCard(
          context,
          title: 'Daily Check-in',
          subtitle: 'Get points for daily visits.',
          icon: Icons.calendar_today_outlined,
          onTap: () => context.go('/daily-check-in'),
          color: Colors.green,
          animationAsset: 'assets/animations/calendar.json',
        ).animate().slideX(begin: -0.5, delay: 200.ms, duration: 500.ms, curve: Curves.easeOut),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required String animationAsset,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Stack(
          children: [
            Positioned(
              right: -50,
              bottom: -40,
              child: Lottie.asset(
                animationAsset,
                width: 180,
                height: 180,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 36, color: color),
                  const SizedBox(height: 12),
                  Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
