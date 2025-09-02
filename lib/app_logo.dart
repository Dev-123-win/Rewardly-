import 'dart:math';

import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 200.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LogoPainter(),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw the purple circle with a gradient
    final circlePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFD1C4E9), Color(0xFF512DA8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius * 0.9, circlePaint);

    // Draw the gold star
    final starPaint = Paint()..color = const Color(0xFFFFD700);
    final starPath = Path();

    final double outerRadius = radius * 0.7;
    final double innerRadius = radius * 0.3;
    const int numPoints = 5;
    const double angle = -pi / 2; // Start at the top

    for (int i = 0; i < numPoints * 2; i++) {
      final double r = (i.isEven) ? outerRadius : innerRadius;
      final double currentAngle = angle + i * pi / numPoints;
      final double x = center.dx + r * cos(currentAngle);
      final double y = center.dy + r * sin(currentAngle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }

    starPath.close();
    canvas.drawPath(starPath, starPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}