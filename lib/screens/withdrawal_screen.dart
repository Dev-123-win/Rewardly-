import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:rewardly/widgets/rewardly_app_bar.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _amountController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const RewardlyAppBar(),
      body: currentUser == null
          ? const Center(child: Text('Please log in to make a withdrawal.'))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData ||
                    snapshot.hasError ||
                    !snapshot.data!.exists) {
                  return const Center(child: Text('Could not load user data.'));
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final points = userData['points'] as int? ?? 0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBalanceCard(theme, points),
                      const SizedBox(height: 32),
                      _buildWithdrawalForm(points),
                      const SizedBox(height: 24),
                      _buildInfoPanel(theme),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildBalanceCard(ThemeData theme, int points) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Your Balance',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              '$points Points',
              style: theme.textTheme.displayMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '(1000 points = ₹1)',
              style: theme.textTheme.titleMedium,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalForm(int currentPoints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount to Withdraw',
            hintText: 'Minimum 1000 points',
            prefixIcon: Icon(Icons.monetization_on_outlined),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => _submitWithdrawal(currentPoints),
          child: const Text('Submit Request'),
        ),
      ],
    );
  }

  Widget _buildInfoPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.secondary,
            size: 28,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Withdrawal requests are processed within 3-5 business days.',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _submitWithdrawal(int currentPoints) async {
    final amount = int.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      _showErrorSnackBar('Please enter a valid amount.');
      return;
    }
    if (amount > currentPoints) {
      _showErrorSnackBar('You do not have enough points.');
      return;
    }
    if (amount < 1000) {
      _showErrorSnackBar('Minimum withdrawal amount is 1000 points.');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('withdrawals').add({
        'userId': currentUser!.uid,
        'amount': amount,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Withdrawal request submitted successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      _showErrorSnackBar('Error submitting request. Please try again.');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
