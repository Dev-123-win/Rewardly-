import 'package:flutter/material.dart';

class Screen {
  final String title;
  final IconData icon;
  final Widget screen;

  const Screen({
    required this.title,
    required this.icon,
    required this.screen,
  });
}
