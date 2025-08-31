import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class FuelGauge extends StatelessWidget {
  final double fuelLevel;
  static const double maxFuel = 100.0;
  static const double lowFuelThreshold = 15.0;

  const FuelGauge({super.key, required this.fuelLevel});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 850;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF00FF41), width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00FF41).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Stack(
        children: [
          // Floating icon for small screens
          if (isSmallScreen)
            Positioned(top: 8, left: 8, child: Icon(Icons.local_gas_station, color: const Color(0xFF00FF41), size: 16)),

          Column(
            children: [
              // Header (only show on normal screens)
              if (!isSmallScreen) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_gas_station, color: const Color(0xFF00FF41), size: 16),
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
              ],

              // Gauge
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: isSmallScreen ? 100 : 120,
                    height: isSmallScreen ? 100 : 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background gauge
                        CustomPaint(
                          size: Size(isSmallScreen ? 100 : 120, isSmallScreen ? 100 : 120),
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
                                fontSize: isSmallScreen ? 20 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (!isSmallScreen)
                              Text('FUEL', style: GoogleFonts.firaCode(color: const Color(0xFF888888), fontSize: 8)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
}

class FuelGaugePainter extends CustomPainter {
  final double fuelLevel;

  const FuelGaugePainter({required this.fuelLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 15;
    final numTicks = 20; // More ticks for htop-style

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Draw background circle
    paint.color = const Color(0xFF333333);
    paint.strokeWidth = 2;
    canvas.drawCircle(center, radius, paint);

    // Calculate current fuel level position
    final normalizedFuel = (fuelLevel / FuelGauge.maxFuel).clamp(0.0, 1.0);
    final currentTickIndex = (normalizedFuel * numTicks).round();

    // Get uniform color for all ticks based on current fuel level criticality
    final currentFuelColor = _getTickColor(fuelLevel);

    // Draw htop-style ticks
    for (int i = 0; i <= numTicks; i++) {
      final angle = -math.pi * 0.75 + (i / numTicks) * math.pi * 1.5;

      // Determine tick color and style based on whether it's active
      Color tickColor;
      if (i <= currentTickIndex) {
        // Active ticks - all use the current fuel level's criticality color
        tickColor = currentFuelColor;
      } else {
        // Inactive ticks - dark gray
        tickColor = const Color(0xFF444444);
      }

      paint.color = tickColor;
      paint.strokeWidth = i <= currentTickIndex ? 4 : 2;

      // Calculate tick positions pointing toward center
      final tickLength = i <= currentTickIndex ? 12 : 8;
      final tickStart =
          center + Offset(math.cos(angle) * (radius - tickLength), math.sin(angle) * (radius - tickLength));
      final tickEnd = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);

      canvas.drawLine(tickStart, tickEnd, paint);
    }

    // Removed gray tick marks for cleaner appearance

    // Low fuel warning indicator (special thick mark)
    if (fuelLevel <= FuelGauge.lowFuelThreshold) {
      final lowFuelAngle = -math.pi * 0.75 + (FuelGauge.lowFuelThreshold / FuelGauge.maxFuel) * math.pi * 1.5;

      paint.color = Colors.red;
      paint.strokeWidth = 5;
      final warningStart =
          center + Offset(math.cos(lowFuelAngle) * (radius - 20), math.sin(lowFuelAngle) * (radius - 20));
      final warningEnd = center + Offset(math.cos(lowFuelAngle) * (radius + 5), math.sin(lowFuelAngle) * (radius + 5));

      canvas.drawLine(warningStart, warningEnd, paint);
    }
  }

  Color _getTickColor(double level) {
    if (level <= FuelGauge.lowFuelThreshold) return const Color(0xFFFF5722); // Red for critical
    if (level <= 25) return const Color(0xFFFF9800); // Orange for low
    if (level <= 50) return const Color(0xFFFFEB3B); // Yellow for medium
    return const Color(0xFF00FF41); // Green for good
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is FuelGaugePainter && oldDelegate.fuelLevel != fuelLevel;
  }
}
