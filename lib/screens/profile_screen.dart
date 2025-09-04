import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rewardly/models/user_tier.dart';
import 'package:rewardly/providers/user_data_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
          title: const Text('My Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Log Out',
            ),
          ],
      ),
      body: Consumer<UserDataProvider>(
        builder: (context, userDataProvider, child) {
          if (userDataProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userDataProvider.userData == null) {
            return _buildLoggedOutView(context, theme);
          }

          return _buildProfileView(context, theme, userDataProvider);
        },
      ),
    );
  }

  Widget _buildLoggedOutView(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 80,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: 20),
            Text(
              'You are not logged in',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Log in to view your profile and start earning rewards!',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, ThemeData theme, UserDataProvider userDataProvider) {
    final userData = userDataProvider.userData!;
    final email = userData['email'] as String? ?? 'No email provided';
    final points = userData['points'] as int? ?? 0;
    final tierIndex = userData['tier'] as int? ?? 0;
    final userTier = UserTier.values.length > tierIndex ? UserTier.values[tierIndex] : UserTier.bronze;
    final bool isAdmin = userData['isAdmin'] == true;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildProfileHeader(theme, email, points, userTier),
        const SizedBox(height: 30),
        _buildProfileActions(context, isAdmin),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'App Version 1.0.0', // This should be dynamically fetched in a real app
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(ThemeData theme, String email, int points, UserTier userTier) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: userTier.color.withAlpha(25),
          child: Icon(
            userTier.icon,
            size: 60,
            color: userTier.color,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          email,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              avatar: Icon(Icons.star_border, color: theme.colorScheme.secondary),
              label: Text(
                '$points Points',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: theme.colorScheme.secondary.withAlpha(25),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            const SizedBox(width: 10),
            Chip(
              avatar: Icon(userTier.icon, color: userTier.color),
              label: Text(
                userTier.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: userTier.color.withAlpha(25),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildProfileActions(BuildContext context, bool isAdmin) {
    return Column(
      children: [
        _buildActionButton(context, icon: Icons.leaderboard, label: 'Achievements', onTap: () => context.go('/achievements')),
        const SizedBox(height: 16),
        _buildActionButton(context, icon: Icons.group_add_outlined, label: 'Refer a Friend', onTap: () => context.go('/referral')),
        const SizedBox(height: 16),
        _buildActionButton(context, icon: Icons.description_outlined, label: 'Terms and Conditions', onTap: () => context.go('/terms')),
        const SizedBox(height: 16),
        _buildActionButton(context, icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', onTap: () => context.go('/privacy-policy')),
        const SizedBox(height: 16),
        _buildActionButton(context, icon: Icons.info_outline, label: 'About Rewardly', onTap: () => context.go('/about')),
        if (isAdmin)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: _buildActionButton(context, icon: Icons.admin_panel_settings_outlined, label: 'Admin Panel', onTap: () => context.go('/admin')),
          ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 28, color: theme.primaryColor),
              const SizedBox(width: 16),
              Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
