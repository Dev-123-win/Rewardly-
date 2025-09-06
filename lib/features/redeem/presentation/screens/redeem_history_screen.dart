import 'package:flutter/material.dart';

class RedeemHistoryScreen extends StatelessWidget {
  const RedeemHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redeem History'),
      ),
      body: const Center(
        child: Text('You have not redeemed any rewards yet.'),
      ),
    );
  }
}
