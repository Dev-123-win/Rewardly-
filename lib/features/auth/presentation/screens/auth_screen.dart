import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_form.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/auth_animation.json', // New animation
                  width: 250,
                  height: 250,
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome to Rewardly',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                const AuthForm(),
                if (authProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: CircularProgressIndicator(),
                  ),
                if (authProvider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      authProvider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
