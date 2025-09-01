import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminHistoryScreen extends StatelessWidget {
  const AdminHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Withdrawal History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('withdrawals')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No withdrawal history found.'));
          }

          final withdrawalDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: withdrawalDocs.length,
            itemBuilder: (context, index) {
              final withdrawal = withdrawalDocs[index];
              final data = withdrawal.data() as Map<String, dynamic>;
              final amount = data['amount'] as int;
              final userId = data['userId'] as String;
              final status = data['status'] as String;
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 4.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(
                    _getStatusIcon(status),
                    color: _getStatusColor(status, theme),
                  ),
                  title: Text('Amount: $amount points - User: ${userId.substring(0, 6)}...', style: theme.textTheme.titleMedium),
                  subtitle: Text(
                    timestamp != null
                        ? 'Requested on ${DateFormat.yMMMd().add_jm().format(timestamp)}'
                        : 'Date not available',
                  ),
                  trailing: Text(
                    status.toUpperCase(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _getStatusColor(status, theme),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'denied':
        return Icons.cancel;
      case 'pending':
      default:
        return Icons.hourglass_empty;
    }
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'denied':
        return Colors.red;
      case 'pending':
      default:
        return theme.colorScheme.onSurface.withOpacity(0.7);
    }
  }
}
