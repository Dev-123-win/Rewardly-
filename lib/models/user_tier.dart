import 'package:flutter/material.dart';

enum UserTier {
  bronze,
  silver,
  gold;

  String get name {
    switch (this) {
      case UserTier.bronze:
        return 'Bronze';
      case UserTier.silver:
        return 'Silver';
      case UserTier.gold:
        return 'Gold';
    }
  }

  Color get color {
    switch (this) {
      case UserTier.bronze:
        return Colors.brown[400]!;
      case UserTier.silver:
        return Colors.grey[400]!;
      case UserTier.gold:
        return Colors.amber;
    }
  }

   IconData get icon {
    switch (this) {
      case UserTier.bronze:
        return Icons.shield;
      case UserTier.silver:
        return Icons.verified;
      case UserTier.gold:
        return Icons.workspace_premium;
    }
  }

  int get minPoints {
    switch (this) {
      case UserTier.bronze:
        return 0;
      case UserTier.silver:
        return 5000;
      case UserTier.gold:
        return 10000;
    }
  }
}
