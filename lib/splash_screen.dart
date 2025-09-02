import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rewardly/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the home screen after a delay
    Future.delayed(const Duration(seconds: 3), () {
      // Use a mounted check to avoid calling context on unmounted widgets
      if (mounted) {
        // You can replace this with your actual home screen navigation logic
        // For example, using go_router
        context.go('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AppLogo(),
      ),
    );
  }
}
