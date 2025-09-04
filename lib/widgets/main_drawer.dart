import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Text(
              'Rewardly',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              context.go('/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              context.go('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.money),
            title: const Text('Withdraw'),
            onTap: () {
              context.go('/withdrawal');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Withdrawal History'),
            onTap: () {
              context.go('/withdrawal-history');
            },
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Referral'),
            onTap: () {
              context.go('/referral');
            },
          ),
           ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Admin'),
            onTap: () {
              context.go('/admin');
            },
          ),
        ],
      ),
    );
  }
}
