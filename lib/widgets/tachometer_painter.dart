import 'package:flutter/material.dart';
import 'dart:math' as math;

class TachometerPainter extends CustomPainter {
  final double rpm;
  static const double maxRpm = 8000;

  const TachometerPainter({required this.rpm});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 15;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Background arc
    paint.color = const Color(0xFF333333);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75, // Start angle
      math.pi * 1.5, // Sweep angle
      false,
      paint,
    );

    // RPM arc
    paint.color = _getRpmColor(rpm);
    paint.strokeWidth = 6;
    final rpmAngle = (rpm / maxRpm) * math.pi * 1.5;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi * 0.75, rpmAngle, false, paint);

    // Tick marks
    paint.strokeWidth = 3;
    paint.color = const Color(0xFF444444); // Dark gray for tachometer marks

    for (int i = 0; i <= 8; i++) {
      final angle = -math.pi * 0.75 + (i / 8) * math.pi * 1.5;
      final tickStart = center + Offset(math.cos(angle) * (radius - 15), math.sin(angle) * (radius - 15));
      final tickEnd = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);

      canvas.drawLine(tickStart, tickEnd, paint);

      // Add RPM labels
      if (i % 2 == 0) {
        final labelPosition = center + Offset(math.cos(angle) * (radius - 30), math.sin(angle) * (radius - 30));

        final textPainter = TextPainter(
          text: TextSpan(
            text: '${i}K',
            style: TextStyle(
              color: const Color(0xFF666666), // Medium gray for labels
              fontSize: 12,
              fontFamily: 'FiraCode',
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, labelPosition - Offset(textPainter.width / 2, textPainter.height / 2));
      }
    }
  }

  Color _getRpmColor(double rpm) {
    if (rpm < 3000) return const Color(0xFF00D9FF); // Cyan for normal RPM
    if (rpm < 5000) return Colors.yellow;
    if (rpm < 6500) return Colors.orange;
    return Colors.red;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is TachometerPainter && oldDelegate.rpm != rpm;
  }
}
