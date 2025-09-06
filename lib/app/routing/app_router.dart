import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rewardly/features/watch_and_earn/presentation/screens/watch_and_earn_screen.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/password_reset_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/daily_check_in_screen.dart';
import '../../features/home/presentation/screens/main_screen.dart';
import '../../features/redeem/presentation/screens/redeem_history_screen.dart';

final GoRouter router = GoRouter(
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = FirebaseAuth.instance.currentUser != null;
    final bool loggingIn = state.matchedLocation.startsWith('/auth');

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
        GoRoute(
          path: 'daily-check-in',
          builder: (BuildContext context, GoRouterState state) {
            return const DailyCheckInScreen();
          },
        ),
        GoRoute(
            path: 'watch-and-earn',
            builder: (context, state) => const WatchAndEarnScreen())
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
          builder: (BuildContext acontext, GoRouterState state) {
            return const PasswordResetScreen();
          },
        ),
      ],
    ),
  ],
);
