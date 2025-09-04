import 'package:flutter/material.dart';
import 'package:rewardly/widgets/rewardly_app_bar.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: RewardlyAppBar(title: 'Withdraw'),
      body: Center(
        child: Text('Withdrawal Screen'),
      ),
    );
  }
}
