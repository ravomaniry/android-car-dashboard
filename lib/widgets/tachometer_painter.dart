import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../themes/dashboard_theme.dart';

class TachometerPainter extends CustomPainter {
  final double rpm;
  final DashboardTheme theme;
  static const double maxRpm = 8000;

  const TachometerPainter({required this.rpm, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 15;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Background arc
    paint.color = theme.inactiveColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75, // Start angle
      math.pi * 1.5, // Sweep angle
      false,
      paint,
    );

    // RPM arc
    paint.color = theme.getRpmColor(rpm);
    paint.strokeWidth = 6;
    final rpmAngle = (rpm / maxRpm) * math.pi * 1.5;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi * 0.75, rpmAngle, false, paint);

    // Tick marks
    paint.strokeWidth = 3;
    paint.color = theme.inactiveColor;

    for (int i = 0; i <= 8; i++) {
      final angle = -math.pi * 0.75 + (i / 8) * math.pi * 1.5;
      final tickStart = center + Offset(math.cos(angle) * (radius - 15), math.sin(angle) * (radius - 15));
      final tickEnd = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);

      canvas.drawLine(tickStart, tickEnd, paint);

      // Add RPM labels
      if (i % 2 == 0) {
        final labelPosition = center + Offset(math.cos(angle) * (radius - 30), math.sin(angle) * (radius - 30));

        final textPainter = TextPainter(
          text: TextSpan(text: '${i}K', style: theme.getBodyTextStyle(fontSize: 12)),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, labelPosition - Offset(textPainter.width / 2, textPainter.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is TachometerPainter && (oldDelegate.rpm != rpm || oldDelegate.theme != theme);
  }
}
