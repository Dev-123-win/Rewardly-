import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewardly/providers/user_data_provider.dart';

class WithdrawalHistoryScreen extends StatefulWidget {
  const WithdrawalHistoryScreen({super.key});

  @override
  State<WithdrawalHistoryScreen> createState() => _WithdrawalHistoryScreenState();
}

class _WithdrawalHistoryScreenState extends State<WithdrawalHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the withdrawal history when the screen is first built.
    Provider.of<UserDataProvider>(context, listen: false).fetchWithdrawalHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdrawal History'),
      ),
      body: Consumer<UserDataProvider>(
        builder: (context, userData, child) {
          if (userData.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (userData.withdrawalHistory.isEmpty) {
            return const Center(
              child: Text('No withdrawal history yet.'),
            );
          }

          return ListView.builder(
            itemCount: userData.withdrawalHistory.length,
            itemBuilder: (context, index) {
              final withdrawal = userData.withdrawalHistory[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text('\$${withdrawal['amount']}'),
                subtitle: Text(withdrawal['date'].toString()),
              );
            },
          );
        },
      ),
    );
  }
}
