import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataProvider with ChangeNotifier {
  Map<String, dynamic>? _userData;
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  StreamSubscription<User?>? _authSubscription;

  Map<String, dynamic>? get userData => _userData;
  int get points => _userData?['points'] ?? 0;

  UserDataProvider() {
    // Listen to authentication changes to start/stop listening to user data
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    if (user != null) {
      // User is signed in, set up a real-time listener on their document
      _listenToUserData(user.uid);
    } else {
      // User is signed out, clear the data and cancel the listener
      _userData = null;
      _userSubscription?.cancel();
      notifyListeners();
    }
  }

  void _listenToUserData(String uid) {
    // Cancel any existing listener
    _userSubscription?.cancel();

    // Listen to the user's document in the 'users' collection
    _userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _userData = snapshot.data();
      } else {
        // Handle case where user document might not exist yet
        _userData = null;
      }
      // Notify all listening widgets that the data has changed
      notifyListeners();
    }, onError: (error, stackTrace) {
       developer.log(
        'Error listening to user data',
        name: 'UserDataProvider',
        error: error,
        stackTrace: stackTrace,
      );
      _userData = null;
      notifyListeners();
    });
  }

  // It's crucial to cancel subscriptions when the provider is no longer needed
  @override
  void dispose() {
    _userSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
