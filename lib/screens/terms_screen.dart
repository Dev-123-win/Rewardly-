import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Welcome to Rewardly! These terms and conditions outline the rules and regulations for the use of our application.',
            ),
            SizedBox(height: 16),
            Text(
              '1. Introduction',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'By using Rewardly, you agree to be bound by these terms and conditions. If you do not agree to these terms, you may not use our application.',
            ),
            SizedBox(height: 16),
            Text(
              '2. User Accounts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account or password.',
            ),
            SizedBox(height: 16),
            Text(
              '3. Rewards',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Rewards are subject to availability and may be changed at any time without notice. We are not responsible for any loss or damage resulting from the redemption of rewards.',
            ),
            SizedBox(height: 16),
            Text(
              '4. Termination',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We may terminate or suspend your account at any time, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the terms.',
            ),
            SizedBox(height: 16),
            Text(
              '5. Changes to Terms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We reserve the right to modify these terms and conditions at any time. Your continued use of the application after any such changes constitutes your acceptance of the new terms.',
            ),
          ],
        ),
      ),
    );
  }
}
