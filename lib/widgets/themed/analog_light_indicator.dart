import 'package:flutter/material.dart';

/// Analog light indicator that looks like a classic car dashboard light
class AnalogLightIndicator extends StatelessWidget {
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final double size;
  final IconData? icon;
  final String? label;

  const AnalogLightIndicator({
    super.key,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    this.size = 24.0,
    this.icon,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: AnalogLightPainter(
        isActive: isActive,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        icon: icon,
        label: label,
      ),
    );
  }
}

class AnalogLightPainter extends CustomPainter {
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final IconData? icon;
  final String? label;

  AnalogLightPainter({
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    this.icon,
    this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint();

    // Draw outer ring (chrome bezel)
    paint.color = Colors.grey[600]!;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    canvas.drawCircle(center, radius - 1, paint);

    // Draw inner background
    paint.style = PaintingStyle.fill;
    paint.color = Colors.black;
    canvas.drawCircle(center, radius - 3, paint);

    // Draw the indicator light
    if (isActive) {
      // Glowing effect
      paint.color = activeColor.withValues(alpha: 0.3);
      canvas.drawCircle(center, radius - 3, paint);

      paint.color = activeColor.withValues(alpha: 0.6);
      canvas.drawCircle(center, radius - 5, paint);

      paint.color = activeColor;
      canvas.drawCircle(center, radius - 7, paint);
    } else {
      paint.color = inactiveColor.withValues(alpha: 0.3);
      canvas.drawCircle(center, radius - 5, paint);
    }

    // Draw icon if provided
    if (icon != null) {
      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon!.codePoint),
          style: TextStyle(
            fontSize: size.width * 0.4,
            fontFamily: icon!.fontFamily,
            color: isActive ? Colors.white : inactiveColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      iconPainter.layout();

      final iconOffset = Offset(center.dx - iconPainter.width / 2, center.dy - iconPainter.height / 2);
      iconPainter.paint(canvas, iconOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is AnalogLightPainter &&
        (oldDelegate.isActive != isActive ||
            oldDelegate.activeColor != activeColor ||
            oldDelegate.inactiveColor != inactiveColor);
  }
}
