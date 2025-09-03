import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:rewardly/models/user_tier.dart';
import 'package:rewardly/services/device_info_service.dart';
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
  final DeviceInfoService _deviceInfoService = DeviceInfoService();
  bool _isLoading = false;
  String? _errorMessage;

  String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  int _getReferrerBonus(UserTier tier) {
    switch (tier) {
      case UserTier.gold:
        return 1000;
      case UserTier.silver:
        return 750;
      case UserTier.bronze:
        return 500;
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final deviceId = await _deviceInfoService.getDeviceId();
      if (deviceId == null) {
        setState(() {
          _errorMessage = "Could not retrieve device ID. Please try again.";
          _isLoading = false;
        });
        return;
      }

      final firestore = FirebaseFirestore.instance;

      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final newUser = credential.user;
      if (newUser == null) return;

      await firestore.runTransaction((transaction) async {
        final deviceDocRef = firestore.collection('deviceIds').doc(deviceId);
        final deviceDoc = await transaction.get(deviceDocRef);

        if (deviceDoc.exists) {
          throw FirebaseException(
              plugin: 'firestore',
              code: 'aborted',
              message: 'This device is already associated with an account.');
        }

        int initialPoints = 100; // Base points
        String? referredBy = _referralCodeController.text.trim();
        DocumentReference? referrerDocRef;
        int referrerBonus = 0;

        if (referredBy.isNotEmpty) {
          final querySnapshot = await firestore
              .collection('users')
              .where('referralCode', isEqualTo: referredBy)
              .limit(1)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            final referrerDoc = querySnapshot.docs.first;
            referrerDocRef = referrerDoc.reference;
            final referrerData = referrerDoc.data();

            initialPoints += 250; // New user gets 250 points

            final referrerTierIndex =
                referrerData['tier'] as int? ?? UserTier.bronze.index;
            final referrerTier = UserTier.values[referrerTierIndex];
            referrerBonus = _getReferrerBonus(referrerTier);
          } else {
            throw FirebaseException(
                plugin: 'firestore',
                code: 'aborted',
                message: 'Invalid referral code. Please check and try again.');
          }
        }

        final newUserDocRef = firestore.collection('users').doc(newUser.uid);
        transaction.set(newUserDocRef, {
          'email': _emailController.text,
          'points': initialPoints,
          'tier': UserTier.bronze.index,
          'referralCode': _generateReferralCode(),
          'referredBy': referredBy.isNotEmpty ? referrerDocRef!.id : null,
          'createdAt': FieldValue.serverTimestamp(),
          'adsWatchedToday': 0,
          'dailyStreak': 0,
          'lastAdWatchedDate': Timestamp.fromDate(DateTime(2000)),
          'deviceId': deviceId,
        });

        transaction.set(deviceDocRef, {'userId': newUser.uid});

        if (referrerDocRef != null) {
          transaction
              .update(referrerDocRef, {'points': FieldValue.increment(referrerBonus)});
        }
      });

      if (mounted) {
        context.go('/');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } on FirebaseException catch (e) {
      if (e.message != null) {
        _errorMessage = e.message;
      } else {
        _errorMessage = "An unexpected error occurred. Please try again.";
      }
      setState(() {});
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
                const SizedBox(height: 24),
                _buildPolicyLinks(context),
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
        prefixIcon: Icon(Icons.lock_outlined),
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

  Widget _buildPolicyLinks(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => context.go('/terms'),
          child: const Text('Terms of Service'),
        ),
        const Text('|'),
        TextButton(
          onPressed: () => context.go('/privacy'),
          child: const Text('Privacy Policy'),
        ),
      ],
    );
  }
}
