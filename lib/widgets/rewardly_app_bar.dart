import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RewardlyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RewardlyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        'Rewardly',
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {
            if (GoRouterState.of(context).uri.toString() != '/profile') {
              context.go('/profile');
            }
          },
          tooltip: 'Profile',
        ),
        IconButton(
          icon: const Icon(Icons.logout_outlined),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              context.go('/login');
            }
          },
          tooltip: 'Logout',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
