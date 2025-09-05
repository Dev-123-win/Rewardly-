import 'package:flutter/material.dart';

class WatchAndEarnProvider with ChangeNotifier {
  int _points = 0;
  int _adsWatched = 0;

  int get points => _points;
  int get adsWatched => _adsWatched;

  void watchAd() {
    if (_adsWatched < 10) {
      _adsWatched++;
      _points += 10; // Assuming 10 points per ad
      notifyListeners();
    }
  }
}
