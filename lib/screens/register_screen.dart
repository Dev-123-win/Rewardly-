import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:rewardly/models/user_tier.dart';
import 'dart:math';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _referralCodeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create the new user
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final newUser = credential.user;
      if (newUser == null) return;

      int initialPoints = 100; // Default starting points
      String? referredBy = _referralCodeController.text.trim();
      DocumentReference? referrerDocRef;

      // Check if a referral code was entered and is valid
      if (referredBy.isNotEmpty) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('referralCode', isEqualTo: referredBy)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          referrerDocRef = querySnapshot.docs.first.reference;
          initialPoints += 50; // Bonus points for the new user
        } else {
          // Handle invalid referral code
          setState(() {
            _errorMessage = 'Invalid referral code. Please check and try again.';
            _isLoading = false;
          });
          return;
        }
      }

      // Use a batch write for atomic operations
      final batch = FirebaseFirestore.instance.batch();

      // 1. Create the new user's document
      final newUserDocRef = FirebaseFirestore.instance.collection('users').doc(newUser.uid);
      batch.set(newUserDocRef, {
        'email': _emailController.text,
        'points': initialPoints,
        'tier': UserTier.bronze.index,
        'referralCode': _generateReferralCode(),
        'referredBy': referredBy.isNotEmpty ? referrerDocRef!.id : null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Reward the referrer if one exists
      if (referrerDocRef != null) {
        batch.update(referrerDocRef, {
          'points': FieldValue.increment(100), // Bonus points for the referrer
        });
      }

      // Commit the batch
      await batch.commit();

      if (mounted) {
        context.go('/');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "An unexpected error occurred. Please try again.";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create Account',
                  style: theme.textTheme.displayLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Join the Rewardly community!',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 20),
                _buildConfirmPasswordField(),
                const SizedBox(height: 20),
                _buildReferralCodeField(),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 32),
                _buildRegisterButton(),
                const SizedBox(height: 24),
                _buildLoginButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (value) =>
          value == null || !value.contains('@') ? 'Enter a valid email' : null,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock_outlined),
      ),
      validator: (value) =>
          value == null || value.length < 6 ? 'Password is too short' : null,
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Confirm Password',
        prefixIcon: Icon(Icons.lock_outline),
      ),
      validator: (value) => value != _passwordController.text
          ? 'Passwords do not match'
          : null,
    );
  }

    Widget _buildReferralCodeField() {
    return TextFormField(
      controller: _referralCodeController,
      decoration: const InputDecoration(
        labelText: 'Referral Code (Optional)',
        prefixIcon: Icon(Icons.group_add_outlined),
      ),
    );
  }


  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _register,
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Register'),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return TextButton(
      onPressed: () => context.go('/login'),
      child: const Text('Already have an account? Login'),
    );
  }
}
