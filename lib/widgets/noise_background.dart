import 'dart:math';

import 'package:flutter/material.dart';

class NoiseBackground extends StatelessWidget {
  const NoiseBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: NoisePainter(),
        ),
        if (child != null) child!,
      ],
    );
  }
}

class NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withAlpha(12);
    final random = Random();

    for (int i = 0; i < size.width * size.height / 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
