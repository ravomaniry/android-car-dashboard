import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class FuelGauge extends StatelessWidget {
  final double fuelLevel;
  static const double maxFuel = 100.0;
  static const double lowFuelThreshold = 15.0;

  const FuelGauge({
    super.key,
    required this.fuelLevel,
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
                Icons.local_gas_station,
                color: const Color(0xFF00FF41),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'FUEL LEVEL',
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
                      painter: FuelGaugePainter(fuelLevel: fuelLevel),
                    ),

                    // Fuel level display
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${fuelLevel.toInt()}%',
                          style: GoogleFonts.orbitron(
                            color: _getFuelColor(fuelLevel),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'FUEL',
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

          // Range estimate
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color(0xFF333333),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RANGE',
                  style: GoogleFonts.firaCode(
                    color: const Color(0xFF888888),
                    fontSize: 8,
                  ),
                ),
                Text(
                  '${_calculateRange(fuelLevel)} km',
                  style: GoogleFonts.firaCode(
                    color: const Color(0xFF00FF41),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _getFuelColor(fuelLevel),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getFuelStatus(fuelLevel),
                  style: GoogleFonts.firaCode(
                    color: _getFuelColor(fuelLevel),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  _getFuelIcon(fuelLevel),
                  color: _getFuelColor(fuelLevel),
                  size: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getFuelColor(double level) {
    if (level <= lowFuelThreshold) return Colors.red;
    if (level <= 25) return Colors.orange;
    return const Color(0xFF00FF41);
  }

  String _getFuelStatus(double level) {
    if (level <= lowFuelThreshold) return 'LOW FUEL';
    if (level <= 25) return 'QUARTER';
    if (level >= 90) return 'FULL';
    return 'GOOD';
  }

  IconData _getFuelIcon(double level) {
    if (level <= lowFuelThreshold) return Icons.warning;
    if (level >= 90) return Icons.check_circle_outline;
    return Icons.local_gas_station;
  }

  int _calculateRange(double level) {
    // Assuming 50L tank and 8L/100km consumption
    const double tankCapacity = 50.0;
    const double consumption = 8.0; // L/100km

    final double currentFuel = (level / 100) * tankCapacity;
    final double range = (currentFuel / consumption) * 100;

    return range.round();
  }
}

class FuelGaugePainter extends CustomPainter {
  final double fuelLevel;

  const FuelGaugePainter({required this.fuelLevel});

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

    // Fuel level arc
    final normalizedFuel = (fuelLevel / FuelGauge.maxFuel).clamp(0.0, 1.0);
    final fuelAngle = normalizedFuel * math.pi * 1.5;

    paint.color = _getArcColor(fuelLevel);
    paint.strokeWidth = 10;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      fuelAngle,
      false,
      paint,
    );

    // Tick marks
    paint.strokeWidth = 2;
    paint.color = const Color(0xFF00FF41);

    for (int i = 0; i <= 4; i++) {
      final angle = -math.pi * 0.75 + (i / 4) * math.pi * 1.5;
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

    // Low fuel warning indicator
    final lowFuelAngle = -math.pi * 0.75 + (FuelGauge.lowFuelThreshold / FuelGauge.maxFuel) * math.pi * 1.5;

    paint.color = Colors.red;
    paint.strokeWidth = 3;
    final warningStart = center +
        Offset(
          math.cos(lowFuelAngle) * (radius - 15),
          math.sin(lowFuelAngle) * (radius - 15),
        );
    final warningEnd = center +
        Offset(
          math.cos(lowFuelAngle) * (radius + 5),
          math.sin(lowFuelAngle) * (radius + 5),
        );

    canvas.drawLine(warningStart, warningEnd, paint);
  }

  Color _getArcColor(double level) {
    if (level <= FuelGauge.lowFuelThreshold) return Colors.red;
    if (level <= 25) return Colors.orange;
    return const Color(0xFF00FF41);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is FuelGaugePainter && oldDelegate.fuelLevel != fuelLevel;
  }
}
