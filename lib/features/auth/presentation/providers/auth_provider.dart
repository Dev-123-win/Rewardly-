import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get currentUser => _auth.currentUser;

  Future<void> _executeAuthAction(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          _errorMessage = 'Wrong password provided for that user.';
          break;
        case 'email-already-in-use':
          _errorMessage = 'The account already exists for that email.';
          break;
        case 'weak-password':
          _errorMessage = 'The password provided is too weak.';
          break;
        default:
          _errorMessage = e.message;
      }
    } catch (e) {
      _errorMessage = 'An unknown error occurred.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    await _executeAuthAction(() => _auth.signInWithEmailAndPassword(email: email, password: password));
  }

  Future<void> signUp(String email, String password) async {
    await _executeAuthAction(() => _auth.createUserWithEmailAndPassword(email: email, password: password));
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _executeAuthAction(() => _auth.sendPasswordResetEmail(email: email));
  }

  Future<void> signOut() async {
    await _executeAuthAction(() => _auth.signOut());
  }
}
