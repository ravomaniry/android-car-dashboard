import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class CenterInstruments extends StatelessWidget {
  final double speed;
  final double rpm;
  final double tripDistance;
  final double fuelUsage;
  final double avgTemperature;
  final double avgSpeed;

  const CenterInstruments({
    super.key,
    required this.speed,
    required this.rpm,
    required this.tripDistance,
    required this.fuelUsage,
    required this.avgTemperature,
    required this.avgSpeed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Speedometer and Tachometer
        Expanded(
          flex: 3,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Tachometer (outer circle)
              CustomPaint(
                size: const Size(200, 200),
                painter: TachometerPainter(rpm: rpm),
              ),
              // Speedometer (center)
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0A),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00FF41),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FF41).withOpacity(0.3),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      speed.toInt().toString(),
                      style: GoogleFonts.orbitron(
                        color: const Color(0xFF00FF41),
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'KM/H',
                      style: GoogleFonts.firaCode(
                        color: const Color(0xFF888888),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // RPM indicator
              Positioned(
                bottom: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00FF41),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${(rpm / 1000).toStringAsFixed(1)}K RPM',
                    style: GoogleFonts.firaCode(
                      color: const Color(0xFF00FF41),
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Trip details
        Expanded(
          flex: 2,
          child: Container(
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
                  color: const Color(0xFF00FF41).withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      color: const Color(0xFF00FF41),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TRIP ANALYSIS',
                      style: GoogleFonts.firaCode(
                        color: const Color(0xFF00FF41),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Trip data grid
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildTripItem(
                              'DISTANCE',
                              '${tripDistance.toStringAsFixed(1)} km',
                              Icons.straighten,
                            ),
                            const SizedBox(height: 8),
                            _buildTripItem(
                              'FUEL USE',
                              '${fuelUsage.toStringAsFixed(1)} L/100km',
                              Icons.local_gas_station,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: [
                            _buildTripItem(
                              'AVG TEMP',
                              '${avgTemperature.toStringAsFixed(0)}°C',
                              Icons.thermostat,
                            ),
                            const SizedBox(height: 8),
                            _buildTripItem(
                              'AVG SPEED',
                              '${avgSpeed.toStringAsFixed(1)} km/h',
                              Icons.speed,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTripItem(String label, String value, IconData icon) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF333333),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF00FF41),
            size: 16,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.firaCode(
              color: const Color(0xFF888888),
              fontSize: 8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.firaCode(
              color: const Color(0xFF00FF41),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
    final radius = size.width / 2 - 10;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

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
    paint.strokeWidth = 4;
    final rpmAngle = (rpm / maxRpm) * math.pi * 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      rpmAngle,
      false,
      paint,
    );

    // Tick marks
    paint.strokeWidth = 2;
    paint.color = const Color(0xFF00FF41);

    for (int i = 0; i <= 8; i++) {
      final angle = -math.pi * 0.75 + (i / 8) * math.pi * 1.5;
      final tickStart = center +
          Offset(
            math.cos(angle) * (radius - 10),
            math.sin(angle) * (radius - 10),
          );
      final tickEnd = center +
          Offset(
            math.cos(angle) * radius,
            math.sin(angle) * radius,
          );

      canvas.drawLine(tickStart, tickEnd, paint);
    }
  }

  Color _getRpmColor(double rpm) {
    if (rpm < 3000) return const Color(0xFF00FF41);
    if (rpm < 5000) return Colors.yellow;
    if (rpm < 6500) return Colors.orange;
    return Colors.red;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is TachometerPainter && oldDelegate.rpm != rpm;
  }
}
