import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class SpeedometerWidget extends StatelessWidget {
  final double speed;
  final double rpm;

  const SpeedometerWidget({
    super.key,
    required this.speed,
    required this.rpm,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate size based on available space
        final size =
            constraints.maxHeight < constraints.maxWidth ? constraints.maxHeight * 0.95 : constraints.maxWidth * 0.95;
        final speedometerSize = size * 0.7;

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Tachometer (outer circle) - bigger
              CustomPaint(
                size: Size(size, size),
                painter: TachometerPainter(rpm: rpm),
              ),
              // Speedometer (center) - bigger, completely borderless
              Container(
                width: speedometerSize,
                height: speedometerSize,
                decoration: const BoxDecoration(
                  color: Color(0xFF0A0A0A),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      speed.toInt().toString(),
                      style: GoogleFonts.orbitron(
                        color: const Color(0xFF00D9FF), // Cyan for speedometer
                        fontSize: size * 0.25, // Responsive font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'KM/H',
                      style: GoogleFonts.firaCode(
                        color: const Color(0xFF888888),
                        fontSize: size * 0.06, // Responsive font size
                      ),
                    ),
                  ],
                ),
              ),
              // RPM indicator
              Positioned(
                bottom: size * 0.15,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: size * 0.06, vertical: size * 0.02),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF00D9FF), // Cyan border for RPM indicator
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${(rpm / 1000).toStringAsFixed(1)}K RPM',
                    style: GoogleFonts.firaCode(
                      color: const Color(0xFF00D9FF), // Cyan for RPM
                      fontSize: size * 0.045, // Responsive font size
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

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
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      rpmAngle,
      false,
      paint,
    );

    // Tick marks
    paint.strokeWidth = 3;
    paint.color = const Color(0xFF444444); // Dark gray for tachometer marks

    for (int i = 0; i <= 8; i++) {
      final angle = -math.pi * 0.75 + (i / 8) * math.pi * 1.5;
      final tickStart = center +
          Offset(
            math.cos(angle) * (radius - 15),
            math.sin(angle) * (radius - 15),
          );
      final tickEnd = center +
          Offset(
            math.cos(angle) * radius,
            math.sin(angle) * radius,
          );

      canvas.drawLine(tickStart, tickEnd, paint);

      // Add RPM labels
      if (i % 2 == 0) {
        final labelPosition = center +
            Offset(
              math.cos(angle) * (radius - 30),
              math.sin(angle) * (radius - 30),
            );

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
        textPainter.paint(
          canvas,
          labelPosition - Offset(textPainter.width / 2, textPainter.height / 2),
        );
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
