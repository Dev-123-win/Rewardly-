import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:rewardly/widgets/rewardly_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const RewardlyAppBar(),
      body: currentUser == null
          ? _buildLoggedOutView(context, theme)
          : _buildProfileView(context, theme),
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

  Widget _buildProfileView(BuildContext context, ThemeData theme) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.hasError || !snapshot.data!.exists) {
          return const Center(child: Text('Could not load user data.'));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final email = userData['email'] as String? ?? 'No email provided';
        final points = userData['points'] as int? ?? 0;

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildProfileHeader(theme, email, points),
            const SizedBox(height: 30),
            _buildProfileActions(context),
          ],
        );
      },
    );
  }

  Widget _buildProfileHeader(ThemeData theme, String email, int points) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.person_outline,
            size: 60,
            color: theme.primaryColor,
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
        Chip(
          avatar: Icon(Icons.star_border, color: theme.colorScheme.secondary),
          label: Text(
            '$points Points',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ],
    );
  }

  Widget _buildProfileActions(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          context,
          icon: Icons.account_balance_wallet_outlined,
          label: 'Request Withdrawal',
          onTap: () => context.go('/withdrawal'),
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          context,
          icon: Icons.history_outlined,
          label: 'Withdrawal History',
          onTap: () => context.go('/withdrawal_history'),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Card(
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
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
