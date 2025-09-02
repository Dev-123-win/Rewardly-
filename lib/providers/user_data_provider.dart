import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rewardly/models/user_tier.dart';

class UserDataProvider with ChangeNotifier {
  Map<String, dynamic>? _userData;
  StreamSubscription<User?>? _authSubscription;
  bool _isLoading = true;
  bool _isHandlingReward = false;

  Map<String, dynamic>? get userData => _userData;
  int get points => _userData?['points'] ?? 0;
  bool get isLoading => _isLoading;

  UserDataProvider() {
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    if (user != null) {
      fetchUserData(user.uid);
    } else {
      _userData = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _getDefaultUserData() {
    return {
      'points': 0,
      'tier': UserTier.bronze.index,
      'dailyStreak': 0,
      'adsWatchedToday': 0,
      'lastAdWatchedDate': Timestamp.now(),
    };
  }

  Future<void> fetchUserData(String uid) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snapshot.exists) {
        _userData = snapshot.data();
      } else {
        _userData = _getDefaultUserData();
      }
    } catch (error, stackTrace) {
      developer.log('Error fetching user data', name: 'UserDataProvider', error: error, stackTrace: stackTrace);
      _userData = _getDefaultUserData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> handleReward(int pointsToAward) async {
    if (_isHandlingReward) {
      return {'success': false, 'message': 'Reward processing already in progress.'};
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'success': false, 'message': 'User not logged in'};
    }

    _isHandlingReward = true;

    try {
      final Map<String, dynamic> currentData = Map<String, dynamic>.from(_userData ?? _getDefaultUserData());

      final today = DateTime.now();
      final lastAdDate = (currentData['lastAdWatchedDate'] as Timestamp).toDate();
      final isNewDay = today.difference(lastAdDate).inDays > 0;

      int adsWatchedToday = currentData['adsWatchedToday'];
      int dailyStreak = currentData['dailyStreak'];

      if (isNewDay) {
        if (today.difference(lastAdDate).inDays > 1) {
          dailyStreak = 0;
        }
        adsWatchedToday = 0;
      }

      if (adsWatchedToday >= 10) {
        return {'success': false, 'message': 'Daily reward limit reached.'};
      }

      adsWatchedToday++;
      // BUG 5 FIX: Use null-aware operator to prevent crash if 'points' is missing.
      int newPoints = (currentData['points'] ?? 0) + pointsToAward;

      bool dailyGoalCompleted = false;
      if (adsWatchedToday == 5) {
        dailyStreak++;
        dailyGoalCompleted = true;
      }

      UserTier currentTier = UserTier.values[currentData['tier']];
      UserTier newTier = currentTier;
      bool tierPromoted = false;
      String newTierName = '';

      if (dailyStreak >= 30 && newTier == UserTier.silver) {
        newTier = UserTier.gold;
        tierPromoted = true;
        newTierName = 'Gold';
      } else if (dailyStreak >= 7 && newTier == UserTier.bronze) {
        newTier = UserTier.silver;
        tierPromoted = true;
        newTierName = 'Silver';
      }

      final Map<String, dynamic> updatedData = {
        'points': newPoints,
        'adsWatchedToday': adsWatchedToday,
        'dailyStreak': dailyStreak,
        'lastAdWatchedDate': Timestamp.now(),
        'tier': newTier.index,
      };

      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDocRef.set(updatedData, SetOptions(merge: true));

      _userData = updatedData;
      notifyListeners();

      return {
        'success': true,
        'dailyGoalCompleted': dailyGoalCompleted,
        // BUG 6 FIX: Corrected typo from 'daily Streak' to 'dailyStreak'
        'newStreak': dailyStreak,
        'tierPromoted': tierPromoted,
        'newTierName': newTierName,
      };

    } catch (error, stackTrace) {
      developer.log('Error updating user data', name: 'UserDataProvider', error: error, stackTrace: stackTrace);
      return {'success': false, 'message': 'Error saving data.'};
    } finally {
      _isHandlingReward = false;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
