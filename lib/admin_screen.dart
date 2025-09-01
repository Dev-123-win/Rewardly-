import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Withdrawal Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.go('/admin-history'),
            tooltip: 'Withdrawal History',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('withdrawals').where('status', isEqualTo: 'pending').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final withdrawalDocs = snapshot.data!.docs;

          if (withdrawalDocs.isEmpty) {
            return const Center(child: Text('No pending withdrawal requests.'));
          }

          return ListView.builder(
            itemCount: withdrawalDocs.length,
            itemBuilder: (context, index) {
              final withdrawal = withdrawalDocs[index];
              final withdrawalId = withdrawal.id;
              final data = withdrawal.data() as Map<String, dynamic>;
              final amount = data['amount'];
              final userId = data['userId'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 4.0,
                child: ListTile(
                  title: Text('Amount: \$$amount'),
                  subtitle: Text('User ID: $userId'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _updateWithdrawalStatus(withdrawalId, 'approved'),
                        tooltip: 'Approve',
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _updateWithdrawalStatus(withdrawalId, 'denied'),
                        tooltip: 'Deny',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _updateWithdrawalStatus(String withdrawalId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('withdrawals').doc(withdrawalId).update({'status': newStatus});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Withdrawal $newStatus successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating withdrawal: $e')),
        );
      }
    }
  }
}
