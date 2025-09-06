
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rewardly/app/models/app_user.dart';

class UserDataProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AppUser? _userModel;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  AppUser? get user => _userModel;

  UserDataProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _listenToUserData(user.uid, user.email ?? '');
      } else {
        _cancelSubscription();
      }
    });
  }

  void _listenToUserData(String uid, String email) {
    _cancelSubscription();
    _userSubscription = _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((doc) async {
      if (doc.exists) {
        _userModel = AppUser.fromDoc(doc);
      } else {
        _userModel = AppUser(uid: uid, email: email);
        await _firestore.collection('users').doc(uid).set({
          'email': email,
          'points': 0,
          'streak': 0,
          'tier': 'Bronze',
          'referralsCount': 0,
        });
      }
      notifyListeners();
    }, onError: (error) {
      debugPrint("Error listening to user data: $error");
      _userModel = null;
      notifyListeners();
    });
  }

  /// Immediately increments the points in the local user model.
  void incrementPoints(int pointsToAdd) {
    if (_userModel != null) {
      _userModel = _userModel!.copyWith(
        points: _userModel!.points + pointsToAdd,
      );
      notifyListeners();
    }
  }

  Future<void> updatePoints(int pointsToAdd) async {
    if (_userModel != null) {
      try {
        await _firestore.collection('users').doc(_userModel!.uid).update({
          'points': FieldValue.increment(pointsToAdd),
        });
      } catch (e) {
        debugPrint("Error updating points: $e");
        // Optionally, rethrow or handle the error in the UI
      }
    }
  }

  bool get canCheckIn {
    if (_userModel?.lastCheckIn == null) {
      return true;
    }
    final now = DateTime.now();
    final lastCheckInDate = _userModel!.lastCheckIn!;
    return now.difference(lastCheckInDate).inDays > 0;
  }

  Future<void> checkIn() async {
    if (_userModel != null && canCheckIn) {
      final now = DateTime.now();
      final newStreak = (_userModel!.streak > 0 && now.difference(_userModel!.lastCheckIn!).inDays == 1) ? _userModel!.streak + 1 : 1;
      await _firestore.collection('users').doc(_userModel!.uid).update({
        'lastCheckIn': Timestamp.fromDate(now),
        'streak': newStreak,
        'points': FieldValue.increment(10), // Award 10 points for check-in
      });
    }
  }

  void _cancelSubscription() {
    _userSubscription?.cancel();
    _userSubscription = null;
    _userModel = null;
    // No notifyListeners() here to prevent unnecessary rebuilds on logout
  }

  @override
  void dispose() {
    _cancelSubscription();
    super.dispose();
  }
}
