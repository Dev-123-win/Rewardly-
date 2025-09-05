import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/watch_and_earn_provider.dart';

class WatchAndEarnScreen extends StatelessWidget {
  const WatchAndEarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch & Earn'),
      ),
      body: ChangeNotifierProvider(
        create: (_) => WatchAndEarnProvider(),
        child: Consumer<WatchAndEarnProvider>(
          builder: (context, provider, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Total Points: ${provider.points}',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Ads Watched Today: ${provider.adsWatched} / 10',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: provider.adsWatched < 10 ? () => provider.watchAd() : null,
                    child: const Text('Watch Ad'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
