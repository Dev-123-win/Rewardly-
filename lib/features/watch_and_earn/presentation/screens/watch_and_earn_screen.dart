import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../providers/watch_and_earn_provider.dart';

class WatchAndEarnScreen extends StatefulWidget {
  const WatchAndEarnScreen({super.key});

  @override
  State<WatchAndEarnScreen> createState() => _WatchAndEarnScreenState();
}

class _WatchAndEarnScreenState extends State<WatchAndEarnScreen> {
  bool _showSuccessAnimation = false;
  int _previousPoints = 0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WatchAndEarnProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Watch & Earn'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Consumer<WatchAndEarnProvider>(
          builder: (context, provider, child) {
            // Show success animation when points increase
            if (provider.points > _previousPoints) {
              setState(() {
                _showSuccessAnimation = true;
              });
              Timer(const Duration(seconds: 2), () {
                setState(() {
                  _showSuccessAnimation = false;
                });
              });
            }
            _previousPoints = provider.points;

            return Stack(
              children: [
                Lottie.asset(
                  'assets/animations/coin.json',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                if (_showSuccessAnimation)
                  Center(
                    child: Lottie.asset(
                      'assets/animations/success.json',
                      width: 200,
                      height: 200,
                      repeat: false,
                    ),
                  ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Total Points',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      Text(
                        '${provider.points}',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Ads Watched Today: ${provider.dailyAdCount} / 10',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: (provider.isAdReady && !provider.isAdLimitReached && !provider.isTimeLimitActive)
                            ? () {
                                HapticFeedback.lightImpact();
                                provider.showAd();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _buildButtonChild(provider),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildButtonChild(WatchAndEarnProvider provider) {
    if (provider.isAdLimitReached) {
      return const Text('Daily Limit Reached');
    } else if (provider.isTimeLimitActive) {
      return const Text('Please wait...');
    } else if (!provider.isAdReady) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset('assets/animations/loading.json', height: 24),
          const SizedBox(width: 8),
          const Text('Loading Ad'),
        ],
      );
    } else {
      return const Text('Watch Ad & Earn');
    }
  }
}
