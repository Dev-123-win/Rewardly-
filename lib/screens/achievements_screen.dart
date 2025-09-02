import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewardly/data/achievements.dart';
import 'package:rewardly/providers/user_data_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final unlockedAchievements = userDataProvider.userData?['unlocked_achievements'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: ListView.builder(
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          final isUnlocked = unlockedAchievements.contains(achievement.id);

          return Card(
            elevation: isUnlocked ? 8 : 2,
            shadowColor: isUnlocked ? Colors.amber.withAlpha(100) : Colors.black.withAlpha(50),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(
                achievement.icon,
                size: 40,
                color: isUnlocked ? Colors.amber : Colors.grey,
              ),
              title: Text(
                achievement.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? Colors.amber : null,
                ),
              ),
              subtitle: Text(achievement.description),
            ),
          );
        },
      ),
    );
  }
}
