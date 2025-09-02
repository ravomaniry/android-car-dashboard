import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/dashboard_state.dart';
import 'dart:async'; // Added for Timer
import 'tachometer_painter.dart';

class SpeedometerWidget extends StatefulWidget {
  final double speed;
  final double rpm;

  const SpeedometerWidget({super.key, required this.speed, required this.rpm});

  @override
  State<SpeedometerWidget> createState() => _SpeedometerWidgetState();
}

class _SpeedometerWidgetState extends State<SpeedometerWidget> with TickerProviderStateMixin {
  bool _showDemoButton = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _showDemoButtonTemporarily() {
    setState(() {
      _showDemoButton = true;
    });

    _fadeController.forward();

    // Cancel existing timer
    _hideTimer?.cancel();

    // Set new timer to hide after 5 seconds
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _fadeController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _showDemoButton = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate size based on available space
        final size = constraints.maxHeight < constraints.maxWidth
            ? constraints.maxHeight * 0.95
            : constraints.maxWidth * 0.95;
        final speedometerSize = size * 0.7;

        return GestureDetector(
          onTap: _showDemoButtonTemporarily,
          child: Container(
            decoration: BoxDecoration(color: const Color(0xFF0A0A0A), borderRadius: BorderRadius.circular(8)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Tachometer (outer circle) - bigger
                CustomPaint(
                  size: Size(size, size),
                  painter: TachometerPainter(rpm: widget.rpm),
                ),
                // Speedometer (center) - bigger, completely borderless
                Container(
                  width: speedometerSize,
                  height: speedometerSize,
                  decoration: const BoxDecoration(color: Color(0xFF0A0A0A), shape: BoxShape.circle),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.speed.toInt().toString(),
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
                      '${(widget.rpm / 1000).toStringAsFixed(1)}K RPM',
                      style: GoogleFonts.firaCode(
                        color: const Color(0xFF00D9FF), // Cyan for RPM
                        fontSize: size * 0.045, // Responsive font size
                      ),
                    ),
                  ),
                ),
                // Demo button - appears when tapped, positioned at bottom right
                if (_showDemoButton)
                  Positioned(
                    bottom: size * 0.05,
                    right: size * 0.05,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Consumer<DashboardState>(
                        builder: (context, dashboardState, child) {
                          return GestureDetector(
                            onTap: () => dashboardState.toggleDemoMode(),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: size * 0.04, vertical: size * 0.02),
                              decoration: BoxDecoration(
                                color: dashboardState.demoMode ? const Color(0xFFFF5722) : const Color(0xFF00FF41),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                dashboardState.demoMode ? 'STOP' : 'DEMO',
                                style: GoogleFonts.firaCode(
                                  color: Colors.white,
                                  fontSize: size * 0.035,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                // Stop button - always visible during demo
                Consumer<DashboardState>(
                  builder: (context, dashboardState, child) {
                    if (!dashboardState.demoMode) return const SizedBox.shrink();

                    return Positioned(
                      bottom: size * 0.05,
                      left: size * 0.05,
                      child: GestureDetector(
                        onTap: () => dashboardState.toggleDemoMode(),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: size * 0.04, vertical: size * 0.02),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5722),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'STOP',
                            style: GoogleFonts.firaCode(
                              color: Colors.white,
                              fontSize: size * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
