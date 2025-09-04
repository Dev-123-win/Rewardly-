import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewardly/models/user_tier.dart';
import 'package:rewardly/providers/user_data_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: Consumer<UserDataProvider>(
        builder: (context, userData, child) {
          final userTier = UserTier.values[userData.userData?['tier'] ?? 0];

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: UserTier.values.length,
            itemBuilder: (context, index) {
              final tier = UserTier.values[index];
              final isUnlocked = userTier.index >= tier.index;

              return Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tier.icon,
                      size: 50,
                      color: isUnlocked ? tier.color : Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      tier.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? tier.color : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${tier.minPoints} points',
                      style: TextStyle(
                        color: isUnlocked ? tier.color : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
