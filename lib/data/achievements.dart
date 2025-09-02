import 'package:rewardly/models/achievement.dart';
import 'package:flutter/material.dart';

final List<Achievement> achievements = [
  Achievement(
    id: 'streak_starter',
    title: 'Streak Starter',
    description: 'Achieve a 7-day streak.',
    icon: Icons.local_fire_department,
    condition: (userData) => (userData['dailyStreak'] ?? 0) >= 7,
  ),
  Achievement(
    id: 'streak_master',
    title: 'Streak Master',
    description: 'Achieve a 30-day streak.',
    icon: Icons.whatshot,
    condition: (userData) => (userData['dailyStreak'] ?? 0) >= 30,
  ),
  Achievement(
    id: 'points_novice',
    title: 'Points Novice',
    description: 'Earn 1,000 points.',
    icon: Icons.star_border,
    condition: (userData) => (userData['points'] ?? 0) >= 1000,
  ),
  Achievement(
    id: 'points_adept',
    title: 'Points Adept',
    description: 'Earn 10,000 points.',
    icon: Icons.star_half,
    condition: (userData) => (userData['points'] ?? 0) >= 10000,
  ),
  Achievement(
    id: 'points_expert',
    title: 'Points Expert',
    description: 'Earn 50,000 points.',
    icon: Icons.star,
    condition: (userData) => (userData['points'] ?? 0) >= 50000,
  ),
  Achievement(
    id: 'silver_tier',
    title: 'Silver Tier',
    description: 'Reach the Silver tier.',
    icon: Icons.shield_outlined,
    condition: (userData) => (userData['tier'] ?? 0) >= 1,
  ),
  Achievement(
    id: 'gold_tier',
    title: 'Gold Tier',
    description: 'Reach the Gold tier.',
    icon: Icons.shield,
    condition: (userData) => (userData['tier'] ?? 0) >= 2,
  ),
];
