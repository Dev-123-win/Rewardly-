import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewardly/providers/user_data_provider.dart';
import 'package:intl/intl.dart';

class WithdrawalHistoryScreen extends StatefulWidget {
  const WithdrawalHistoryScreen({super.key});

  @override
  State<WithdrawalHistoryScreen> createState() =>
      _WithdrawalHistoryScreenState();
}

class _WithdrawalHistoryScreenState extends State<WithdrawalHistoryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    
    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
       userDataProvider.fetchWithdrawalHistory(isInitial: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
              _scrollController.position.maxScrollExtent - 100 && // Trigger before hitting the absolute end
          !userDataProvider.isFetchingHistory &&
          userDataProvider.hasMoreHistory) {
        userDataProvider.fetchWithdrawalHistory();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdrawal History'),
      ),
      body: Consumer<UserDataProvider>(
        builder: (context, userData, child) {
          if (userData.isFetchingHistory && userData.withdrawalHistory.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (userData.withdrawalHistory.isEmpty) {
            return const Center(
              child: Text('No withdrawal history yet.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => userData.fetchWithdrawalHistory(isInitial: true),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: userData.withdrawalHistory.length + (userData.hasMoreHistory ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == userData.withdrawalHistory.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final withdrawal = userData.withdrawalHistory[index];
                final date = (withdrawal['date'] as dynamic).toDate();
                final formattedDate = DateFormat.yMMMd().add_jm().format(date);

                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text('\$${withdrawal['amount']}'),
                  subtitle: Text(formattedDate),
                  trailing: Text(
                    withdrawal['status'] ?? 'Completed',
                    style: TextStyle(
                      color: withdrawal['status'] == 'Pending' ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
