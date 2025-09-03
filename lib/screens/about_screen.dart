import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Rewardly'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms & Conditions'),
            onTap: () => context.go('/terms'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () => context.go('/privacy'),
          ),
          // Add this when the how it works screen is ready
          // ListTile(
          //   leading: const Icon(Icons.help_outline),
          //   title: const Text('How It Works'),
          //   onTap: () => context.go('/how-it-works'),
          // ),
        ],
      ),
    );
  }
}
