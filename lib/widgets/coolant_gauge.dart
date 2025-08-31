import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class CoolantGauge extends StatelessWidget {
  final double temperature;
  static const double minTemp = 60.0;
  static const double maxTemp = 120.0;
  static const double optimalTemp = 90.0;

  const CoolantGauge({super.key, required this.temperature});

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
            Positioned(top: 8, left: 8, child: Icon(Icons.thermostat, color: const Color(0xFF00FF41), size: 16)),

          Column(
            children: [
              // Header (only show on normal screens)
              if (!isSmallScreen) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.thermostat, color: const Color(0xFF00FF41), size: 16),
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
                                fontSize: isSmallScreen ? 20 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (!isSmallScreen)
                              Text('CELSIUS', style: GoogleFonts.firaCode(color: const Color(0xFF888888), fontSize: 8)),
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

  Color _getTemperatureColor(double temp) {
    if (temp < 70) return Colors.blue;
    if (temp > 100) return Colors.red;
    return const Color(0xFF00FF41);
  }
}

class CoolantGaugePainter extends CustomPainter {
  final double temperature;

  const CoolantGaugePainter({required this.temperature});

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

    // Calculate current temperature position
    final normalizedTemp = ((temperature - CoolantGauge.minTemp) / (CoolantGauge.maxTemp - CoolantGauge.minTemp)).clamp(
      0.0,
      1.0,
    );
    final currentTickIndex = (normalizedTemp * numTicks).round();

    // Get uniform color for all ticks based on current temperature criticality
    final currentTempColor = _getTickColor(temperature);

    // Draw htop-style ticks
    for (int i = 0; i <= numTicks; i++) {
      final angle = -math.pi * 0.75 + (i / numTicks) * math.pi * 1.5;

      // Determine tick color and style based on whether it's active
      Color tickColor;
      if (i <= currentTickIndex) {
        // Active ticks - all use the current temperature's criticality color
        tickColor = currentTempColor;
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
  }

  Color _getTickColor(double temp) {
    if (temp < 70) return const Color(0xFF00D9FF); // Cyan for cold
    if (temp <= 85) return const Color(0xFF00FF41); // Green for normal
    if (temp <= 95) return const Color(0xFFFFEB3B); // Yellow for warm
    if (temp <= 105) return const Color(0xFFFF9800); // Orange for hot
    return const Color(0xFFFF5722); // Red for overheating
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is CoolantGaugePainter && oldDelegate.temperature != temperature;
  }
}
