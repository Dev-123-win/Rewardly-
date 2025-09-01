import 'package:flutter/material.dart';
import 'package:rewardly/screens/store_screen.dart';

class PointsCard extends StatelessWidget {
  final int points;
  final UserTier userTier;

  const PointsCard({super.key, required this.points, required this.userTier});

  String _getTierName(UserTier tier) {
    switch (tier) {
      case UserTier.gold:
        return 'Gold';
      case UserTier.silver:
        return 'Silver';
      case UserTier.bronze:
      default:
        return 'Bronze';
    }
  }

  Color _getTierColor(UserTier tier, ThemeData theme) {
    switch (tier) {
      case UserTier.gold:
        return Colors.amber;
      case UserTier.silver:
        return Colors.grey[300]!;
      case UserTier.bronze:
      default:
        return theme.colorScheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tierName = _getTierName(userTier);
    final tierColor = _getTierColor(userTier, theme);

    return Card(
      elevation: 12,
      shadowColor: theme.primaryColor.withAlpha(77),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              theme.primaryColor.withOpacity(0.9),
              theme.primaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Points',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              points.toString(),
              style: theme.textTheme.displayLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Chip(
              avatar: Icon(Icons.military_tech, color: tierColor),
              label: Text(
                tierName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.brightness == Brightness.dark ? Colors.black : tierColor,
                ),
              ),
              backgroundColor: theme.scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ],
        ),
      ),
    );
  }
}
