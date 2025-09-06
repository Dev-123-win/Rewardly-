import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rewardly/features/home/presentation/models/screen_model.dart';
import 'package:rewardly/features/home/presentation/screens/home_screen.dart';
import 'package:rewardly/features/profile/presentation/screens/profile_screen.dart';
import 'package:rewardly/features/redeem/presentation/screens/redeem_screen.dart';
import 'package:rewardly/features/watch_and_earn/presentation/screens/watch_and_earn_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _bottomNavIndex = 0;

  final List<Screen> _screens = [
    const Screen(
      title: 'Home',
      icon: Icons.home,
      screen: HomeScreen(),
    ),
    const Screen(
      title: 'Profile',
      icon: Icons.person,
      screen: ProfileScreen(),
    ),
    const Screen(
      title: 'Redeem',
      icon: Icons.redeem,
      screen: RedeemScreen(),
    ),
    const Screen(
      title: 'Watch & Earn',
      icon: Icons.monetization_on,
      screen: WatchAndEarnScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_bottomNavIndex].screen,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.history),
        onPressed: () => context.go('/redeem-history'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: _screens.map((screen) => screen.icon).toList(),
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) => setState(() => _bottomNavIndex = index),
      ),
    );
  }
}
