import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../themes/dashboard_theme.dart';

class DynamicGaugePainter extends CustomPainter {
  final double value;
  final double minValue;
  final double maxValue;
  final DashboardTheme theme;
  final String label;
  final String unit;

  const DynamicGaugePainter({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.theme,
    required this.label,
    required this.unit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (theme.gaugeStyle) {
      case GaugeStyle.htop:
        _paintHtopStyle(canvas, size);
        break;
      case GaugeStyle.analog:
        _paintAnalogStyle(canvas, size);
        break;
      case GaugeStyle.digital:
        _paintDigitalStyle(canvas, size);
        break;
      case GaugeStyle.elegant:
        _paintElegantStyle(canvas, size);
        break;
    }
  }

  void _paintHtopStyle(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 15;
    final numTicks = 20;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    // Draw background
    paint.color = theme.inactiveColor;
    paint.strokeWidth = 2;
    canvas.drawCircle(center, radius, paint);

    // Calculate current value position
    final normalizedValue = ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
    final currentTickIndex = (normalizedValue * numTicks).round();

    // Get color based on value
    final currentColor = _getValueColor(value);

    // Draw ASCII-style ticks
    for (int i = 0; i <= numTicks; i++) {
      final angle = -math.pi * 0.75 + (i / numTicks) * math.pi * 1.5;

      Color tickColor;
      if (i <= currentTickIndex) {
        tickColor = currentColor;
      } else {
        tickColor = theme.inactiveColor;
      }

      paint.color = tickColor;
      paint.strokeWidth = i <= currentTickIndex ? 3 : 1;

      // Draw tick marks (like terminal)
      final tickLength = i <= currentTickIndex ? 10 : 6;
      final tickStart =
          center + Offset(math.cos(angle) * (radius - tickLength), math.sin(angle) * (radius - tickLength));
      final tickEnd = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);

      canvas.drawLine(tickStart, tickEnd, paint);
    }
  }

  void _paintAnalogStyle(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw outer ring with gradient effect
    if (theme.useGradients) {
      paint.shader = RadialGradient(
        colors: [theme.primaryAccentColor.withValues(alpha: 0.8), theme.primaryAccentColor.withValues(alpha: 0.3)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    } else {
      paint.color = theme.primaryAccentColor;
    }
    paint.strokeWidth = 4;
    canvas.drawCircle(center, radius, paint);

    // Draw vintage-style markings
    paint.shader = null;
    for (int i = 0; i <= 12; i++) {
      final angle = -math.pi * 0.75 + (i / 12) * math.pi * 1.5;
      paint.color = theme.secondaryAccentColor;
      paint.strokeWidth = i % 3 == 0 ? 4 : 2;

      final tickLength = i % 3 == 0 ? 20 : 12;
      final tickStart =
          center + Offset(math.cos(angle) * (radius - tickLength), math.sin(angle) * (radius - tickLength));
      final tickEnd = center + Offset(math.cos(angle) * (radius - 5), math.sin(angle) * (radius - 5));

      canvas.drawLine(tickStart, tickEnd, paint);
    }

    // Draw analog needle
    final normalizedValue = ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
    final needleAngle = -math.pi * 0.75 + normalizedValue * math.pi * 1.5;

    paint.color = theme.dangerColor;
    paint.strokeWidth = 6;
    final needleEnd = center + Offset(math.cos(needleAngle) * (radius - 30), math.sin(needleAngle) * (radius - 30));
    canvas.drawLine(center, needleEnd, paint);

    // Draw center hub
    paint.style = PaintingStyle.fill;
    paint.color = theme.primaryAccentColor;
    canvas.drawCircle(center, 8, paint);
  }

  void _paintDigitalStyle(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 15;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Digital segments background
    paint.color = theme.inactiveColor;
    paint.strokeWidth = 8;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi * 0.75, math.pi * 1.5, false, paint);

    // Active digital segments
    final normalizedValue = ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
    final activeAngle = normalizedValue * math.pi * 1.5;

    // Disable gradients for Modern theme to avoid crashes
    paint.color = _getValueColor(value);

    paint.strokeWidth = 12;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi * 0.75, activeAngle, false, paint);

    // Digital glow effect
    if (theme.showDecorations) {
      paint.shader = null;
      paint.color = theme.primaryAccentColor.withValues(alpha: 0.3);
      paint.strokeWidth = 20;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi * 0.75, activeAngle, false, paint);
    }
  }

  void _paintElegantStyle(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 25;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Elegant gradient background
    if (theme.useGradients) {
      paint.shader = RadialGradient(
        colors: [
          theme.containerColor,
          theme.primaryAccentColor.withValues(alpha: 0.1),
          theme.primaryAccentColor.withValues(alpha: 0.3),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius + 25));
    }

    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, radius + 20, paint);

    // Elegant curved segments
    paint.shader = null;
    paint.style = PaintingStyle.stroke;

    final normalizedValue = ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
    final segments = 24;

    for (int i = 0; i < segments; i++) {
      final segmentAngle = (i / segments) * math.pi * 1.5;
      final angle = -math.pi * 0.75 + segmentAngle;

      if (segmentAngle <= normalizedValue * math.pi * 1.5) {
        // Active segments with gradient
        if (theme.useGradients) {
          final progress = segmentAngle / (math.pi * 1.5);
          paint.color = Color.lerp(theme.successColor, theme.primaryAccentColor, progress) ?? theme.primaryAccentColor;
        } else {
          paint.color = _getValueColor(value);
        }
        paint.strokeWidth = 6;
      } else {
        paint.color = theme.inactiveColor;
        paint.strokeWidth = 3;
      }

      // Draw curved segment
      final segmentRadius = radius - 10;
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

    // Decorative elements
    if (theme.showDecorations) {
      paint.color = theme.primaryAccentColor.withValues(alpha: 0.4);
      paint.strokeWidth = 1;
      canvas.drawCircle(center, radius - 30, paint);
      canvas.drawCircle(center, radius + 10, paint);
    }
  }

  Color _getValueColor(double val) {
    final normalized = ((val - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);

    // For Modern theme, use theme colors instead of criticality colors
    if (theme.gaugeStyle == GaugeStyle.digital) {
      if (normalized <= 0.3) return theme.successColor;
      if (normalized <= 0.7) return theme.primaryAccentColor;
      return theme.secondaryAccentColor;
    }

    // For other themes, use criticality colors
    if (normalized <= 0.3) return theme.successColor;
    if (normalized <= 0.7) return theme.warningColor;
    return theme.dangerColor;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is DynamicGaugePainter && (oldDelegate.value != value || oldDelegate.theme != theme);
  }
}
