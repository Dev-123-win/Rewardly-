import 'package:flutter/material.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How It Works'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStep(context, '1', 'Watch Ads, Earn Points', 'Watch short ads to earn points. You can watch up to 10 ads daily.'),
            _buildStep(
              context, 
              '2', 
              'Play the Game', 
              'Collect coins in our endless runner game. The more coins you collect, the more points you can convert.',
              isGame: true
            ),
            _buildStep(context, '3', 'Maintain Your Streak', 'Watch at least 5 ads every day to keep your daily streak alive and earn tier promotions.'),
            _buildStep(context, '4', 'Redeem Your Points', 'Cash out your points for real rewards from the withdrawal section.'),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, String step, String title, String description, {bool isGame = false}) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shadowColor: theme.primaryColor.withAlpha(50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: theme.primaryColor,
              child: Text(step, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),
            Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description, style: theme.textTheme.bodyMedium),
            if (isGame) _buildGameExplanation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGameExplanation(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Coin to Point Conversion:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildTierConversion(context, 'Bronze Tier', '1,000 coins = 500 points'),
          _buildTierConversion(context, 'Silver Tier', '1,000 coins = 750 points'),
          _buildTierConversion(context, 'Gold Tier', '1,000 coins = 1,000 points'),
        ],
      ),
    );
  }

  Widget _buildTierConversion(BuildContext context, String tier, String conversion) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.star, color: theme.colorScheme.secondary, size: 16),
          const SizedBox(width: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$tier: ', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                TextSpan(text: conversion, style: theme.textTheme.bodyMedium),
              ]
            )
          )
        ],
      ),
    );
  }
}
