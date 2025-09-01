import 'package:flutter/material.dart';

class StreakIndicator extends StatelessWidget {
  final int dailyStreak;
  final int adsWatchedToday;

  const StreakIndicator({
    super.key,
    required this.dailyStreak,
    required this.adsWatchedToday,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = adsWatchedToday / 5.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Daily Streak', style: theme.textTheme.titleLarge),
                Text('$dailyStreak Days', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: LinearProgressIndicator(value: progress, minHeight: 10, borderRadius: BorderRadius.circular(5),)),
                const SizedBox(width: 16),
                Text('$adsWatchedToday/5 Ads'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
