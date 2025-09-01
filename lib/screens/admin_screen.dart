import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rewardly/widgets/rewardly_app_bar.dart';
import 'package:rewardly/screens/store_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('users').snapshots();

  void _updateUserTier(String userId, UserTier newTier) {
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'tier': newTier.index,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const RewardlyAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView( // Use a ListView for better performance with long lists
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              final Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              final userTier = UserTier.values[data['tier'] ?? 0];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['email'],
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            label: Text('${data['points']} Points'),
                            avatar: const Icon(Icons.star_border),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(userTier.toString().split('.').last),
                            avatar: const Icon(Icons.military_tech),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTierManagementButtons(document.id, userTier),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildTierManagementButtons(String userId, UserTier currentTier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => _showTierDialog(userId, currentTier),
          child: const Text('Change Tier'),
        ),
      ],
    );
  }

  Future<void> _showTierDialog(String userId, UserTier currentTier) async {
    final UserTier? newTier = await showDialog<UserTier>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Tier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserTier.values.map((tier) {
            return RadioListTile<UserTier>(
              title: Text(tier.toString().split('.').last),
              value: tier,
              groupValue: currentTier,
              onChanged: (UserTier? value) {
                Navigator.of(context).pop(value);
              },
            );
          }).toList(),
        ),
      ),
    );

    if (newTier != null && newTier != currentTier) {
      _updateUserTier(userId, newTier);
    }
  }
}
