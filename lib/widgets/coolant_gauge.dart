import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class CoolantGauge extends StatelessWidget {
  final double temperature;
  static const double minTemp = 60.0;
  static const double maxTemp = 120.0;
  static const double optimalTemp = 90.0;

  const CoolantGauge({
    super.key,
    required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(
          color: const Color(0xFF00FF41),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF41).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.thermostat,
                color: const Color(0xFF00FF41),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'COOLANT',
                style: GoogleFonts.firaCode(
                  color: const Color(0xFF00FF41),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gauge
          Expanded(
            child: Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background gauge
                    CustomPaint(
                      size: const Size(120, 120),
                      painter: CoolantGaugePainter(temperature: temperature),
                    ),

                    // Temperature display
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${temperature.toInt()}°',
                          style: GoogleFonts.orbitron(
                            color: _getTemperatureColor(temperature),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'CELSIUS',
                          style: GoogleFonts.firaCode(
                            color: const Color(0xFF888888),
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _getTemperatureColor(temperature),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getTemperatureStatus(temperature),
                  style: GoogleFonts.firaCode(
                    color: _getTemperatureColor(temperature),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  _getTemperatureIcon(temperature),
                  color: _getTemperatureColor(temperature),
                  size: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTemperatureColor(double temp) {
    if (temp < 70) return Colors.blue;
    if (temp > 100) return Colors.red;
    return const Color(0xFF00FF41);
  }

  String _getTemperatureStatus(double temp) {
    if (temp < 70) return 'COLD';
    if (temp > 100) return 'HOT';
    return 'OPTIMAL';
  }

  IconData _getTemperatureIcon(double temp) {
    if (temp < 70) return Icons.ac_unit;
    if (temp > 100) return Icons.whatshot;
    return Icons.check_circle_outline;
  }
}

class CoolantGaugePainter extends CustomPainter {
  final double temperature;

  const CoolantGaugePainter({required this.temperature});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    // Background arc
    paint.color = const Color(0xFF333333);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75, // Start angle
      math.pi * 1.5, // Sweep angle (270 degrees)
      false,
      paint,
    );

    // Temperature arc
    final normalizedTemp =
        ((temperature - CoolantGauge.minTemp) / (CoolantGauge.maxTemp - CoolantGauge.minTemp)).clamp(0.0, 1.0);
    final tempAngle = normalizedTemp * math.pi * 1.5;

    paint.color = _getArcColor(temperature);
    paint.strokeWidth = 10;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      tempAngle,
      false,
      paint,
    );

    // Tick marks
    paint.strokeWidth = 2;
    paint.color = const Color(0xFF00FF41);

    for (int i = 0; i <= 6; i++) {
      final angle = -math.pi * 0.75 + (i / 6) * math.pi * 1.5;
      final tickStart = center +
          Offset(
            math.cos(angle) * (radius - 8),
            math.sin(angle) * (radius - 8),
          );
      final tickEnd = center +
          Offset(
            math.cos(angle) * radius,
            math.sin(angle) * radius,
          );

      canvas.drawLine(tickStart, tickEnd, paint);
    }

    // Optimal temperature indicator
    final optimalAngle = -math.pi * 0.75 +
        ((CoolantGauge.optimalTemp - CoolantGauge.minTemp) / (CoolantGauge.maxTemp - CoolantGauge.minTemp)) *
            math.pi *
            1.5;

    paint.color = const Color(0xFF00FF41);
    paint.strokeWidth = 3;
    final optimalStart = center +
        Offset(
          math.cos(optimalAngle) * (radius - 15),
          math.sin(optimalAngle) * (radius - 15),
        );
    final optimalEnd = center +
        Offset(
          math.cos(optimalAngle) * (radius + 5),
          math.sin(optimalAngle) * (radius + 5),
        );

    canvas.drawLine(optimalStart, optimalEnd, paint);
  }

  Color _getArcColor(double temp) {
    if (temp < 70) return Colors.blue;
    if (temp > 100) return Colors.red;
    if (temp > 95) return Colors.orange;
    return const Color(0xFF00FF41);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is CoolantGaugePainter && oldDelegate.temperature != temperature;
  }
}
