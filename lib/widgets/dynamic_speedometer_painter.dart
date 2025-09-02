import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../themes/dashboard_theme.dart';

class DynamicSpeedometerPainter extends CustomPainter {
  final double speed;
  final double rpm;
  final DashboardTheme theme;

  const DynamicSpeedometerPainter({required this.speed, required this.rpm, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    switch (theme.gaugeStyle) {
      case GaugeStyle.htop:
        _paintLinuxStyle(canvas, size);
        break;
      case GaugeStyle.analog:
        _paintClassicAnalog(canvas, size);
        break;
      case GaugeStyle.digital:
        _paintModernDigital(canvas, size);
        break;
      case GaugeStyle.elegant:
        _paintElegantStyle(canvas, size);
        break;
    }
  }

  void _paintLinuxStyle(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 30;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    // Terminal-style background
    paint.color = theme.inactiveColor;
    paint.strokeWidth = 2;
    canvas.drawCircle(center, radius, paint);

    // ASCII-style speed segments
    final speedSegments = 40;
    final normalizedSpeed = (speed / 200).clamp(0.0, 1.0);
    final activeSegments = (normalizedSpeed * speedSegments).round();

    for (int i = 0; i < speedSegments; i++) {
      final angle = -math.pi * 1.25 + (i / speedSegments) * math.pi * 1.5;

      if (i < activeSegments) {
        paint.color = theme.speedometerColor;
        paint.strokeWidth = 3;
      } else {
        paint.color = theme.inactiveColor;
        paint.strokeWidth = 1;
      }

      final tickLength = i < activeSegments ? 12 : 8;
      final tickStart =
          center + Offset(math.cos(angle) * (radius - tickLength), math.sin(angle) * (radius - tickLength));
      final tickEnd = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);

      canvas.drawLine(tickStart, tickEnd, paint);
    }

    // Terminal-style RPM outer ring
    _paintLinuxRpm(canvas, size, center, radius + 20);
  }

  void _paintClassicAnalog(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 40;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Vintage gauge background with brass effect
    if (theme.useGradients) {
      paint.shader = RadialGradient(
        colors: [
          theme.containerColor,
          theme.primaryAccentColor.withValues(alpha: 0.2),
          theme.primaryAccentColor.withValues(alpha: 0.4),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius + 30));
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(center, radius + 25, paint);
    }

    // Vintage markings and numbers
    paint.shader = null;
    paint.style = PaintingStyle.stroke;

    // Use single criticality color for all ticks based on current speed
    final tickColor = _getSpeedColor(speed);
    paint.color = tickColor;

    for (int i = 0; i <= 20; i++) {
      final angle = -math.pi * 1.25 + (i / 20) * math.pi * 1.5; // Rotated 90 degrees counterclockwise

      paint.strokeWidth = i % 5 == 0 ? 4 : 2;

      final tickLength = i % 5 == 0 ? 25 : 15;
      final tickStart =
          center + Offset(math.cos(angle) * (radius - tickLength), math.sin(angle) * (radius - tickLength));
      final tickEnd = center + Offset(math.cos(angle) * (radius - 5), math.sin(angle) * (radius - 5));

      canvas.drawLine(tickStart, tickEnd, paint);

      // Vintage numbers
      if (i % 5 == 0) {
        final labelRadius = radius - 35;
        final labelPos = center + Offset(math.cos(angle) * labelRadius, math.sin(angle) * labelRadius);

        final textPainter = TextPainter(
          text: TextSpan(
            text: '${i * 10}',
            style: TextStyle(
              color: tickColor,
              fontSize: 14,
              fontFamily: theme.fontFamily,
              fontWeight: theme.headerFontWeight,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, labelPos - Offset(textPainter.width / 2, textPainter.height / 2));
      }
    }

    // Vintage speed needle
    final normalizedSpeed = (speed / 200).clamp(0.0, 1.0);
    final needleAngle = -math.pi * 1.25 + normalizedSpeed * math.pi * 1.5; // Rotated 90 degrees counterclockwise

    // Use criticality-based color for needle
    paint.color = _getSpeedColor(speed);
    paint.strokeWidth = 8;
    final needleEnd = center + Offset(math.cos(needleAngle) * (radius - 40), math.sin(needleAngle) * (radius - 40));
    canvas.drawLine(center, needleEnd, paint);

    // Vintage center hub
    paint.style = PaintingStyle.fill;
    paint.color = theme.primaryAccentColor;
    canvas.drawCircle(center, 12, paint);

    // RPM removed for analog theme - only speed needle
  }

  void _paintModernDigital(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 25;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Futuristic background
    if (theme.useGradients) {
      paint.shader = RadialGradient(
        colors: [
          theme.backgroundColor,
          theme.primaryAccentColor.withValues(alpha: 0.1),
          theme.primaryAccentColor.withValues(alpha: 0.3),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius + 20));
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(center, radius + 15, paint);
    }

    // Digital speed arc
    paint.shader = null;
    paint.style = PaintingStyle.stroke;
    paint.color = theme.inactiveColor;
    paint.strokeWidth = 12;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi * 1.25, math.pi * 1.5, false, paint);

    // Active speed arc with glow
    final normalizedSpeed = (speed / 200).clamp(0.0, 1.0);
    final activeAngle = normalizedSpeed * math.pi * 1.5;

    if (theme.useGradients) {
      paint.shader = SweepGradient(
        startAngle: -math.pi * 1.25,
        endAngle: -math.pi * 1.25 + activeAngle,
        colors: [theme.successColor, theme.speedometerColor, theme.secondaryAccentColor],
        stops: [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    } else {
      paint.color = _getSpeedColor(speed);
    }

    paint.strokeWidth = 16;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi * 1.25, activeAngle, false, paint);

    // Glow effect
    if (theme.showDecorations) {
      paint.shader = null;
      paint.color = theme.speedometerColor.withValues(alpha: 0.3);
      paint.strokeWidth = 24;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi * 1.25, activeAngle, false, paint);
    }

    // Modern RPM display
    _paintModernRpm(canvas, size, center, radius + 30);
  }

  void _paintElegantStyle(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 35;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Elegant gradient background
    if (theme.useGradients) {
      paint.shader = RadialGradient(
        colors: [
          theme.containerColor,
          theme.primaryAccentColor.withValues(alpha: 0.05),
          theme.primaryAccentColor.withValues(alpha: 0.15),
          theme.primaryAccentColor.withValues(alpha: 0.25),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius + 35));
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(center, radius + 30, paint);
    }

    // Elegant curved segments
    paint.shader = null;
    paint.style = PaintingStyle.stroke;

    final normalizedSpeed = (speed / 200).clamp(0.0, 1.0);
    final segments = 36;

    for (int i = 0; i < segments; i++) {
      final segmentAngle = (i / segments) * math.pi * 1.5;
      final angle = -math.pi * 1.25 + segmentAngle;

      if (segmentAngle <= normalizedSpeed * math.pi * 1.5) {
        if (theme.useGradients) {
          final progress = segmentAngle / (math.pi * 1.5);
          paint.color = Color.lerp(theme.successColor, theme.primaryAccentColor, progress) ?? theme.primaryAccentColor;
        } else {
          paint.color = _getSpeedColor(speed);
        }
        paint.strokeWidth = 8;
      } else {
        paint.color = theme.inactiveColor;
        paint.strokeWidth = 4;
      }

      // Draw elegant curved segment
      final segmentRadius = radius - 15;
      final startAngle = angle - 0.02;
      final endAngle = angle + 0.02;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: segmentRadius),
        startAngle,
        endAngle - startAngle,
        false,
        paint,
      );
    }

    // Decorative rings
    if (theme.showDecorations) {
      paint.color = theme.primaryAccentColor.withValues(alpha: 0.3);
      paint.strokeWidth = 1;
      canvas.drawCircle(center, radius - 35, paint);
      canvas.drawCircle(center, radius + 5, paint);
      canvas.drawCircle(center, radius + 15, paint);
    }

    // Elegant RPM display
    _paintElegantRpm(canvas, size, center, radius + 40);
  }

  void _paintLinuxRpm(Canvas canvas, Size size, Offset center, double rpmRadius) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final normalizedRpm = (rpm / 8000).clamp(0.0, 1.0);
    final rpmSegments = 24;
    final activeRpmSegments = (normalizedRpm * rpmSegments).round();

    for (int i = 0; i < rpmSegments; i++) {
      final angle = -math.pi * 1.25 + (i / rpmSegments) * math.pi * 1.5;

      if (i < activeRpmSegments) {
        paint.color = theme.tachometerColor;
        paint.strokeWidth = 2;
      } else {
        paint.color = theme.inactiveColor;
        paint.strokeWidth = 1;
      }

      final tickLength = 8;
      final tickStart =
          center + Offset(math.cos(angle) * (rpmRadius - tickLength), math.sin(angle) * (rpmRadius - tickLength));
      final tickEnd = center + Offset(math.cos(angle) * rpmRadius, math.sin(angle) * rpmRadius);

      canvas.drawLine(tickStart, tickEnd, paint);
    }
  }

  void _paintModernRpm(Canvas canvas, Size size, Offset center, double rpmRadius) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Digital RPM background
    paint.color = theme.inactiveColor;
    paint.strokeWidth = 6;
    canvas.drawArc(Rect.fromCircle(center: center, radius: rpmRadius), -math.pi * 1.25, math.pi * 1.5, false, paint);

    // Active RPM arc
    final normalizedRpm = (rpm / 8000).clamp(0.0, 1.0);
    final activeRpmAngle = normalizedRpm * math.pi * 1.5;

    paint.color = theme.tachometerColor;
    paint.strokeWidth = 8;
    canvas.drawArc(Rect.fromCircle(center: center, radius: rpmRadius), -math.pi * 1.25, activeRpmAngle, false, paint);
  }

  void _paintElegantRpm(Canvas canvas, Size size, Offset center, double rpmRadius) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final normalizedRpm = (rpm / 8000).clamp(0.0, 1.0);
    final rpmSegments = 20;

    for (int i = 0; i < rpmSegments; i++) {
      final segmentAngle = (i / rpmSegments) * math.pi * 1.5;
      final angle = -math.pi * 1.25 + segmentAngle;

      if (segmentAngle <= normalizedRpm * math.pi * 1.5) {
        paint.color = theme.tachometerColor;
        paint.strokeWidth = 4;
      } else {
        paint.color = theme.inactiveColor;
        paint.strokeWidth = 2;
      }

      final segmentRadius = rpmRadius;
      final startAngle = angle - 0.03;
      final endAngle = angle + 0.03;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: segmentRadius),
        startAngle,
        endAngle - startAngle,
        false,
        paint,
      );
    }
  }

  Color _getSpeedColor(double spd) {
    // For Modern theme, use theme colors instead of criticality colors
    if (theme.gaugeStyle == GaugeStyle.digital) {
      if (spd < 40) return theme.successColor;
      if (spd < 80) return theme.primaryAccentColor;
      return theme.secondaryAccentColor;
    }

    // For other themes, use standardized speed color method
    return theme.getSpeedColor(spd);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is DynamicSpeedometerPainter &&
        (oldDelegate.speed != speed || oldDelegate.rpm != rpm || oldDelegate.theme != theme);
  }
}
