import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rewardly/features/auth/presentation/screens/auth_screen.dart';
import 'package:rewardly/features/home/presentation/screens/home_screen.dart';
import 'package:rewardly/features/home/presentation/screens/main_screen.dart';
import 'package:rewardly/features/home/presentation/screens/profile_screen.dart';
import 'package:rewardly/features/home/presentation/screens/watch_and_earn_screen.dart';

import '../../features/home/presentation/screens/daily_check_in_screen.dart';
import '../../features/redeem/presentation/screens/redeem_history_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final GoRouter router = GoRouter(
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = FirebaseAuth.instance.currentUser != null;
    final bool loggingIn = state.matchedLocation == '/auth';

    if (!loggedIn) {
      return loggingIn ? null : '/auth';
    }

    if (loggingIn) {
      return '/';
    }

    return null;
  },
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) {
        return HomeScreen(child: child);
      },
      routes: [
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
          path: '/profile',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfileScreen();
          },
        ),
      ],
    ),
    GoRoute(
      path: '/auth',
      builder: (BuildContext context, GoRouterState state) {
        return const AuthScreen();
      },
    ),
  ],
);
