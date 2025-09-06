import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Represents the user's data model.
class UserModel {
  final String uid;
  final int points;
  final int streak;
  final DateTime? lastCheckIn;
  final String tier;
  final int referralsCount;
  final DateTime? lastAdWatchedTimestamp;
  final int adsWatchedToday;

  UserModel({
    required this.uid,
    this.points = 0,
    this.streak = 0,
    this.lastCheckIn,
    this.tier = 'Bronze',
    this.referralsCount = 0,
    this.lastAdWatchedTimestamp,
    this.adsWatchedToday = 0,
  });

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      points: data['points'] ?? 0,
      streak: data['streak'] ?? 0,
      lastCheckIn: (data['lastCheckIn'] as Timestamp?)?.toDate(),
      tier: data['tier'] ?? 'Bronze',
      referralsCount: data['referralsCount'] ?? 0,
      lastAdWatchedTimestamp:
          (data['lastAdWatchedTimestamp'] as Timestamp?)?.toDate(),
      adsWatchedToday: data['adsWatchedToday'] ?? 0,
    );
  }
}

class UserDataProvider with ChangeNotifier {
  UserModel? _userModel;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  UserModel? get user => _userModel;

  UserDataProvider() {
    // Listen to auth state changes to start/stop listening to user data
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _listenToUserData(user.uid);
      } else {
        _cancelSubscription();
      }
    });
  }

  void _listenToUserData(String uid) {
    _cancelSubscription(); // Ensure any existing subscription is cancelled
    _userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        _userModel = UserModel.fromDoc(doc);
      } else {
        // Handle case where user doc might not exist yet
        _userModel = UserModel(uid: uid); 
      }
      notifyListeners();
    }, onError: (error) {
      print("Error listening to user data: $error");
      _userModel = null;
      notifyListeners();
    });
  }

  void _cancelSubscription() {
    _userSubscription?.cancel();
    _userSubscription = null;
    _userModel = null;
  }

  @override
  void dispose() {
    _cancelSubscription();
    super.dispose();
  }
}
