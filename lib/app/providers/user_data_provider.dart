
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// Represents the user's data model.
class UserModel {
  final String uid;
  final String email;
  final int points;
  final int streak;
  final DateTime? lastCheckIn;
  final String tier;
  final int referralsCount;

  UserModel({
    required this.uid,
    required this.email,
    this.points = 0,
    this.streak = 0,
    this.lastCheckIn,
    this.tier = 'Bronze',
    this.referralsCount = 0,
  });

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      points: data['points'] ?? 0,
      streak: data['streak'] ?? 0,
      lastCheckIn: (data['lastCheckIn'] as Timestamp?)?.toDate(),
      tier: data['tier'] ?? 'Bronze',
      referralsCount: data['referralsCount'] ?? 0,
    );
  }

  // Create a copy of the user model with new values
  UserModel copyWith({
    int? points,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      points: points ?? this.points,
      streak: streak,
      lastCheckIn: lastCheckIn,
      tier: tier,
      referralsCount: referralsCount,
    );
  }
}

class UserDataProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _userModel;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  UserModel? get user => _userModel;

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
        _userModel = UserModel.fromDoc(doc);
      } else {
        _userModel = UserModel(uid: uid, email: email);
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
