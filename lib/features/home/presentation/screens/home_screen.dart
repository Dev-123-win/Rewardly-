import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/providers/user_data_provider.dart';
import '../../../../app/theme/theme_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userDataProvider = Provider.of<UserDataProvider>(context);

    final user = userDataProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewardly'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              tooltip: 'Logout',
            )
          else
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () => context.go('/auth'),
              tooltip: 'Authentication',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (user != null)
              _buildWelcomeHeader(context, user)
            else
              _buildGuestHeader(context),            
            const SizedBox(height: 30),
            _buildFeatureCard(
              context,
              icon: Icons.monetization_on,
              title: 'Watch & Earn',
              subtitle: 'Watch ads to earn points',
              onTap: () => context.go('/watch-and-earn'),
              delay: 700.ms,
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              icon: Icons.calendar_today,
              title: 'Daily Check-in',
              subtitle: 'Earn points for checking in daily',
              onTap: () => context.go('/daily-check-in'),
              delay: 900.ms,
            ),
            const Spacer(),
             if (user == null)
              ElevatedButton(
                onPressed: () => context.go('/auth'),
                child: const Text('Get Started'),
              ).animate().fadeIn(delay: 1100.ms),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, UserModel user) {
    return Column(
      children: [
         Text('Welcome back!', style: Theme.of(context).textTheme.headlineMedium)
              .animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: -0.2, duration: 400.ms),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(context, 'Points', user.points.toString()),
              _buildStatItem(context, 'Streak', '${user.streak} days'),
            ],
          ),
      ],
    );
  }

  Widget _buildGuestHeader(BuildContext context) {
    return Text('Welcome to Rewardly!', style: Theme.of(context).textTheme.displayLarge)
        .animate()
        .fadeIn(delay: 300.ms)
        .slideY(begin: 0.5, duration: 600.ms);
  }


  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium)
            .animate()
            .fadeIn(delay: 500.ms)
            .scale(),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap, required Duration delay,}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay).slideX(begin: -0.5, duration: 500.ms);
  }
}
