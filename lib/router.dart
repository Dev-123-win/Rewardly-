import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:rewardly/admin_screen.dart';
import 'package:rewardly/screens/auth_screen.dart';
import 'package:rewardly/screens/home_screen.dart';
import 'package:rewardly/screens/profile_screen.dart';
import 'package:rewardly/screens/withdrawal_screen.dart';
import 'package:rewardly/screens/withdrawal_history_screen.dart';
import 'package:rewardly/screens/admin_history_screen.dart';

// Helper class to notify the router of auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final GoRouter router = GoRouter(
  refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'profile',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfileScreen();
          },
        ),
        GoRoute(
          path: 'withdrawal',
          builder: (BuildContext context, GoRouterState state) {
            return const WithdrawalScreen();
          },
        ),
        GoRoute(
          path: 'withdrawal-history',
          builder: (BuildContext context, GoRouterState state) {
            return const WithdrawalHistoryScreen();
          },
        ),
        GoRoute(
          path: 'admin',
          builder: (BuildContext context, GoRouterState state) {
            return const AdminScreen();
          },
        ),
        GoRoute(
          path: 'admin-history',
          builder: (BuildContext context, GoRouterState state) {
            return const AdminHistoryScreen();
          },
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const AuthScreen();
      },
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = FirebaseAuth.instance.currentUser != null;
    final bool loggingIn = state.matchedLocation == '/login';

    // If the user is not logged in and not on the login page, redirect to login
    if (!loggedIn && !loggingIn) {
      return '/login';
    }

    // If the user is logged in and on the login page, redirect to home
    if (loggedIn && loggingIn) {
      return '/';
    }

    // No redirect needed
    return null;
  },
);
