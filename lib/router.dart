import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rewardly/main_screen.dart';
import 'package:rewardly/providers/auth_provider.dart';
import 'package:rewardly/screens/about_screen.dart';
import 'package:rewardly/screens/achievements_screen.dart';
import 'package:rewardly/screens/admin_history_screen.dart';
import 'package:rewardly/screens/admin_screen.dart';
import 'package:rewardly/screens/game_screen.dart';
import 'package:rewardly/screens/home_screen.dart';
import 'package:rewardly/screens/how_it_works_screen.dart';
import 'package:rewardly/screens/login_screen.dart';
import 'package:rewardly/screens/privacy_policy_screen.dart';
import 'package:rewardly/screens/profile_screen.dart';
import 'package:rewardly/screens/referral_screen.dart';
import 'package:rewardly/screens/register_screen.dart';
import 'package:rewardly/screens/terms_screen.dart';
import 'package:rewardly/screens/withdrawal_history_screen.dart';
import 'package:rewardly/screens/withdrawal_screen.dart';
import 'package:rewardly/splash_screen.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/withdrawal',
        builder: (context, state) => const WithdrawalScreen(),
      ),
      GoRoute(
        path: '/withdrawal-history',
        builder: (context, state) => const WithdrawalHistoryScreen(),
      ),
      GoRoute(
        path: '/referral',
        builder: (context, state) => const ReferralScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: '/admin-history',
        builder: (context, state) => const AdminHistoryScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) => const GameScreen(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/how-it-works',
        builder: (context, state) => const HowItWorksScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bool loggedIn = authProvider.user != null;
      final bool isLoading = authProvider.isLoading;

      final bool isGoingToLogin = state.matchedLocation == '/login';
      final bool isGoingToRegister = state.matchedLocation == '/register';
      final bool isGoingToSplash = state.matchedLocation == '/splash';

      final publicRoutes = ['/terms', '/privacy-policy'];
      final bool isPublicRoute = publicRoutes.contains(state.matchedLocation);

      if (isLoading) {
        return isGoingToSplash ? null : '/splash';
      }

      if (loggedIn && (isGoingToLogin || isGoingToRegister || isGoingToSplash)) {
        return '/';
      }

      if (!loggedIn && !isGoingToLogin && !isGoingToRegister && !isPublicRoute) {
        return '/login';
      }

      return null;
    },
  );
}
