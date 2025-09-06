
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rewardly/app/providers/user_data_provider.dart';

class DailyCheckInScreen extends StatelessWidget {
  const DailyCheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userDataProvider = context.watch<UserDataProvider>();
    final canCheckIn = userDataProvider.canCheckIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Check-in'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/calendar.json',
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 30),
            if (canCheckIn)
              ElevatedButton(
                onPressed: () {
                  userDataProvider.checkIn();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You have checked in for today!')),
                  );
                },
                child: const Text('Check-in Now'),
              )
            else
              const Text('You have already checked in today.'),
          ],
        ),
      ),
    );
  }
}
