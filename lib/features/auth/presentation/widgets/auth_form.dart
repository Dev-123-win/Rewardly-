import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _userEmail = '';
  var _userPassword = '';
  bool _obscurePassword = true;

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (_isLogin) {
        authProvider.signIn(_userEmail, _userPassword);
      } else {
        authProvider.signUp(_userEmail, _userPassword);
      }
    }
  }

  void _resetPassword() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // A simple dialog to get the user's email
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          onChanged: (value) => _userEmail = value,
          decoration: const InputDecoration(labelText: 'Enter your email'),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Reset'),
            onPressed: () {
              if (_userEmail.isNotEmpty) {
                authProvider.sendPasswordResetEmail(_userEmail);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset link sent to your email.'),
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            key: const ValueKey('email'),
            validator: (value) {
              if (value == null || !value.contains('@')) {
                return 'Please enter a valid email address.';
              }
              return null;
            },
            onSaved: (value) {
              _userEmail = value!;
            },
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const ValueKey('password'),
            validator: (value) {
              if (value == null || value.length < 7) {
                return 'Password must be at least 7 characters long.';
              }
              return null;
            },
            onSaved: (value) {
              _userPassword = value!;
            },
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
          if (!_isLogin) const SizedBox(height: 12),
          if (!_isLogin)
            TextFormField(
              key: const ValueKey('confirm_password'),
              validator: (value) {
                if (value != _userPassword) {
                  return 'Passwords do not match!';
                }
                return null;
              },
              obscureText: _obscurePassword,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _trySubmit,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(_isLogin ? 'Login' : 'Signup'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isLogin = !_isLogin;
                _formKey.currentState?.reset();
              });
            },
            child: Text(_isLogin
                ? 'Create new account'
                : 'I already have an account'),
          ),
          if (_isLogin)
            TextButton(
              onPressed: _resetPassword,
              child: const Text('Forgot Password?'),
            ),
        ].animate(interval: 100.ms).fadeIn().slideY(begin: 0.5),
      ),
    );
  }
}
