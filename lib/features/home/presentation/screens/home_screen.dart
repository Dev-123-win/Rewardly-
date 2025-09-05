import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/theme_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () => context.go('/auth'),
            tooltip: 'Authentication',
          ),
          IconButton(
            icon: const Icon(Icons.monetization_on),
            onPressed: () => context.go('/watch-and-earn'),
            tooltip: 'Watch & Earn',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome!', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 20),
            Text('This is the rebuilt application.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: () => context.go('/auth'), child: const Text('Get Started')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => context.go('/watch-and-earn'), child: const Text('Watch & Earn')),
          ],
        ),
      ),
    );
  }
}
