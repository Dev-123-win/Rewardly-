import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rewardly/models/user_tier.dart';

class UserDataProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  List<Map<String, dynamic>> _withdrawalHistory = [];

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  int get points => _userData?['points'] ?? 0;
  List<Map<String, dynamic>> get withdrawalHistory => _withdrawalHistory;

  UserDataProvider() {
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      _isLoading = true;
      notifyListeners();

      try {
        final snapshot = await _db.collection('users').doc(user.uid).get();
        if (snapshot.exists) {
          _userData = snapshot.data();
        } else {
          _userData = null;
        }
      } catch (e) {
        // Handle error appropriately
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchWithdrawalHistory() async {
    final user = _auth.currentUser;
    if (user != null) {
      final historySnapshot = await _db
          .collection('users')
          .doc(user.uid)
          .collection('withdrawals')
          .orderBy('date', descending: true)
          .get();

      _withdrawalHistory = historySnapshot.docs.map((doc) => doc.data()).toList();
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> handleReward(int rewardAmount, {bool isGameReward = false}) async {
    final user = _auth.currentUser;
    if (user == null) {
      return {'success': false, 'message': 'User not logged in'};
    }

    final userRef = _db.collection('users').doc(user.uid);

    try {
      return await _db.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception("User document does not exist!");
        }

        final currentData = userDoc.data() as Map<String, dynamic>;
        final adsWatchedToday = currentData['adsWatchedToday'] ?? 0;

        if (!isGameReward && adsWatchedToday >= 10) {
          return {'success': false, 'message': 'Daily ad limit reached'};
        }

        final newPoints = (currentData['points'] ?? 0) + rewardAmount;
        final newAdsWatched = isGameReward ? adsWatchedToday : adsWatchedToday + 1;
        
        final lastAdWatchedDate = currentData['lastAdWatchedDate']?.toDate();
        final now = DateTime.now();
        int newDailyStreak = currentData['dailyStreak'] ?? 0;

        if (lastAdWatchedDate == null) {
          newDailyStreak = 1;
        } else {
          final difference = now.difference(lastAdWatchedDate).inHours;
          if (difference >= 24 && difference < 48) {
            newDailyStreak++;
          } else if (difference >= 48) {
            newDailyStreak = 1;
          }
        }

        final newTier = UserTier.values.lastWhere(
          (tier) => newPoints >= tier.minPoints,
          orElse: () => UserTier.bronze, // Default to bronze
        );

        transaction.update(userRef, {
          'points': newPoints,
          'adsWatchedToday': newAdsWatched,
          'tier': newTier.index,
          'lastAdWatchedDate': FieldValue.serverTimestamp(),
          'dailyStreak': newDailyStreak,
        });

        await fetchUserData();

        return {'success': true, 'message': 'Reward processed'};
      });
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
