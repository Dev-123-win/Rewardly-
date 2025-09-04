import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewardly/providers/user_data_provider.dart';

class AuthProvider with ChangeNotifier {
  final BuildContext context;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User? _user;
  bool _isLoading = true;
  StreamSubscription<User?>? _authStateSubscription;

  User? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider(this.context) {
    _authStateSubscription = _auth.authStateChanges().listen(_onAuthStateChanged, onError: (error) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    _isLoading = false;
    if (user != null) {
      await Provider.of<UserDataProvider>(context, listen: false).init();
    } else {
      Provider.of<UserDataProvider>(context, listen: false).clearData();
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (result.user != null) {
        await _db.collection('users').doc(result.user!.uid).set({
          'email': email,
          'points': 0,
          'tier': 0,
          'adsWatchedToday': 0,
          'dailyStreak': 0,
          'lastAdWatchedDate': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
