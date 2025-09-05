import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/password_reset_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/main_screen.dart';
import '../../features/redeem/presentation/screens/redeem_history_screen.dart';

final GoRouter router = GoRouter(
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = FirebaseAuth.instance.currentUser != null;
    final bool loggingIn = state.matchedLocation == '/auth' ||
        state.matchedLocation == '/auth/signup' ||
        state.matchedLocation == '/auth/password-reset';

    if (!loggedIn) {
      return loggingIn ? null : '/auth';
    }

    if (loggingIn) {
      return '/';
    }

    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const MainScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'redeem-history',
          builder: (BuildContext context, GoRouterState state) {
            return const RedeemHistoryScreen();
          },
        ),
      ],
    ),
    GoRoute(
      path: '/auth',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
      routes: [
        GoRoute(
          path: 'signup',
          builder: (BuildContext context, GoRouterState state) {
            return const SignupScreen();
          },
        ),
        GoRoute(
          path: 'password-reset',
          builder: (BuildContext context, GoRouterState state) {
            return const PasswordResetScreen();
          },
        ),
      ],
    ),
  ],
);
