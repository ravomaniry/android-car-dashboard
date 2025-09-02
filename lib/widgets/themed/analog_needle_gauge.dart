import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Classic analog needle gauge like traditional car dashboards
class AnalogNeedleGauge extends StatelessWidget {
  final double value;
  final double minValue;
  final double maxValue;
  final String label;
  final String unit;
  final Color needleColor;
  final Color backgroundColor;
  final Color tickColor;
  final Color textColor;
  final List<String>? tickLabels;

  const AnalogNeedleGauge({
    super.key,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.label,
    required this.unit,
    required this.needleColor,
    required this.backgroundColor,
    required this.tickColor,
    required this.textColor,
    this.tickLabels,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: AnalogNeedleGaugePainter(
        value: value,
        minValue: minValue,
        maxValue: maxValue,
        label: label,
        unit: unit,
        needleColor: needleColor,
        backgroundColor: backgroundColor,
        tickColor: tickColor,
        textColor: textColor,
        tickLabels: tickLabels,
      ),
    );
  }
}

class AnalogNeedleGaugePainter extends CustomPainter {
  final double value;
  final double minValue;
  final double maxValue;
  final String label;
  final String unit;
  final Color needleColor;
  final Color backgroundColor;
  final Color tickColor;
  final Color textColor;
  final List<String>? tickLabels;

  AnalogNeedleGaugePainter({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.label,
    required this.unit,
    required this.needleColor,
    required this.backgroundColor,
    required this.tickColor,
    required this.textColor,
    this.tickLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    final paint = Paint();

    // Draw gauge background (black circle)
    paint.color = backgroundColor;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);

    // Draw outer chrome ring
    paint.color = Colors.grey[400]!;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3.0;
    canvas.drawCircle(center, radius - 2, paint);

    // Draw tick marks and labels
    _drawTickMarks(canvas, center, radius, paint);

    // Draw needle
    _drawNeedle(canvas, center, radius);

    // Draw center hub
    paint.color = Colors.grey[600]!;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, paint);

    paint.color = Colors.grey[400]!;
    canvas.drawCircle(center, 6, paint);

    // Draw label at bottom
    _drawLabel(canvas, center, radius);
  }

  void _drawTickMarks(Canvas canvas, Offset center, double radius, Paint paint) {
    const startAngle = -math.pi * 1.25; // -225 degrees (90 degrees counterclockwise from -135)
    const sweepAngle = math.pi * 1.5; // 270 degrees
    const majorTicks = 5;
    const minorTicksPerMajor = 4;

    for (int i = 0; i <= majorTicks; i++) {
      final angle = startAngle + (i / majorTicks) * sweepAngle;

      // Major tick
      paint.color = tickColor;
      paint.strokeWidth = 2.0;
      final majorTickStart = center + Offset(math.cos(angle) * (radius - 20), math.sin(angle) * (radius - 20));
      final majorTickEnd = center + Offset(math.cos(angle) * (radius - 5), math.sin(angle) * (radius - 5));
      canvas.drawLine(majorTickStart, majorTickEnd, paint);

      // Tick label
      if (tickLabels != null && i < tickLabels!.length) {
        _drawTickLabel(canvas, center, angle, radius - 35, tickLabels![i]);
      } else {
        final tickValue = minValue + (i / majorTicks) * (maxValue - minValue);
        _drawTickLabel(canvas, center, angle, radius - 35, tickValue.toInt().toString());
      }

      // Minor ticks
      if (i < majorTicks) {
        for (int j = 1; j <= minorTicksPerMajor; j++) {
          final minorAngle = angle + (j / (minorTicksPerMajor + 1)) * (sweepAngle / majorTicks);
          paint.strokeWidth = 1.0;
          final minorTickStart =
              center + Offset(math.cos(minorAngle) * (radius - 15), math.sin(minorAngle) * (radius - 15));
          final minorTickEnd =
              center + Offset(math.cos(minorAngle) * (radius - 5), math.sin(minorAngle) * (radius - 5));
          canvas.drawLine(minorTickStart, minorTickEnd, paint);
        }
      }
    }
  }

  void _drawTickLabel(Canvas canvas, Offset center, double angle, double radius, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final labelPos =
        center +
        Offset(math.cos(angle) * radius - textPainter.width / 2, math.sin(angle) * radius - textPainter.height / 2);
    textPainter.paint(canvas, labelPos);
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    final normalizedValue = ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
    const startAngle = -math.pi * 1.25; // -225 degrees (90 degrees counterclockwise from -135)
    const sweepAngle = math.pi * 1.5;
    final needleAngle = startAngle + normalizedValue * sweepAngle;

    final paint = Paint()
      ..color = needleColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Needle line
    final needleEnd = center + Offset(math.cos(needleAngle) * (radius - 25), math.sin(needleAngle) * (radius - 25));
    canvas.drawLine(center, needleEnd, paint);

    // Needle tip (triangle)
    final tipPath = Path();
    final tipWidth = 4.0;

    final tipPoint = center + Offset(math.cos(needleAngle) * (radius - 15), math.sin(needleAngle) * (radius - 15));

    final perpAngle1 = needleAngle + math.pi / 2;
    final perpAngle2 = needleAngle - math.pi / 2;

    final tip1 = tipPoint + Offset(math.cos(perpAngle1) * tipWidth, math.sin(perpAngle1) * tipWidth);
    final tip2 = tipPoint + Offset(math.cos(perpAngle2) * tipWidth, math.sin(perpAngle2) * tipWidth);

    tipPath.moveTo(needleEnd.dx, needleEnd.dy);
    tipPath.lineTo(tip1.dx, tip1.dy);
    tipPath.lineTo(tip2.dx, tip2.dy);
    tipPath.close();

    paint.style = PaintingStyle.fill;
    canvas.drawPath(tipPath, paint);
  }

  void _drawLabel(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final labelPos = Offset(center.dx - textPainter.width / 2, center.dy + radius * 0.4);
    textPainter.paint(canvas, labelPos);

    // Value display
    final valuePainter = TextPainter(
      text: TextSpan(
        text: '${value.toInt()}$unit',
        style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    valuePainter.layout();

    final valuePos = Offset(center.dx - valuePainter.width / 2, center.dy + radius * 0.6);
    valuePainter.paint(canvas, valuePos);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is AnalogNeedleGaugePainter &&
        (oldDelegate.value != value ||
            oldDelegate.needleColor != needleColor ||
            oldDelegate.backgroundColor != backgroundColor);
  }
}
