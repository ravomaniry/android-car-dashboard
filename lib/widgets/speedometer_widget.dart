import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/dashboard_state.dart';
import '../themes/dashboard_theme.dart';
import 'dart:async'; // Added for Timer
import 'dynamic_speedometer_painter.dart';
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
          onPanUpdate: (details) {
            // Handle swipe gestures for theme switching
            if (details.delta.dx.abs() > details.delta.dy.abs()) {
              // Horizontal swipe detected
              if (details.delta.dx > 10) {
                // Swipe right - cycle to next theme
                context.read<DashboardState>().cycleTheme();
              } else if (details.delta.dx < -10) {
                // Swipe left - cycle to previous theme (reverse direction)
                final dashboardState = context.read<DashboardState>();
                // Cycle backwards by going forward twice
                dashboardState.cycleTheme();
                dashboardState.cycleTheme();
              }
            }
          },
          child: Consumer<DashboardState>(
            builder: (context, dashboardState, child) {
              final theme = dashboardState.currentTheme;

              return Container(
                decoration: BoxDecoration(
                  color: theme.backgroundColor,
                  borderRadius: BorderRadius.circular(theme.borderRadius),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Use original tachometer for Linux theme, dynamic for others
                    if (theme.gaugeStyle == GaugeStyle.htop) ...[
                      // Original Linux tachometer
                      CustomPaint(
                        size: Size(size, size),
                        painter: TachometerPainter(rpm: widget.rpm, theme: theme),
                      ),
                      // Original speedometer center display
                      Container(
                        width: speedometerSize,
                        height: speedometerSize,
                        decoration: BoxDecoration(color: theme.backgroundColor, shape: BoxShape.circle),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.speed.toInt().toString(),
                              style: GoogleFonts.orbitron(
                                color: theme.speedometerColor,
                                fontSize: size * 0.25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('KM/H', style: theme.getBodyTextStyle(fontSize: size * 0.06)),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Dynamic speedometer and tachometer for other themes
                      CustomPaint(
                        size: Size(size, size),
                        painter: DynamicSpeedometerPainter(speed: widget.speed, rpm: widget.rpm, theme: theme),
                      ),
                      // Speed display (only show for some themes)
                      if (theme.gaugeStyle == GaugeStyle.digital || theme.gaugeStyle == GaugeStyle.elegant)
                        Container(
                          width: speedometerSize * 0.6,
                          height: speedometerSize * 0.6,
                          decoration: BoxDecoration(
                            color: theme.containerColor.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.borderColor, width: theme.borderWidth),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.speed.toInt().toString(),
                                style: GoogleFonts.orbitron(
                                  color: theme.speedometerColor,
                                  fontSize: size * 0.18,
                                  fontWeight: theme.headerFontWeight,
                                ),
                              ),
                              Text('KM/H', style: theme.getBodyTextStyle(fontSize: size * 0.04)),
                            ],
                          ),
                        ),
                      // Analog speed display (classic theme)
                      if (theme.gaugeStyle == GaugeStyle.analog)
                        Positioned(
                          bottom: size * 0.25,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: size * 0.04, vertical: size * 0.02),
                            decoration: BoxDecoration(
                              color: theme.containerColor,
                              borderRadius: BorderRadius.circular(theme.borderRadius),
                              border: Border.all(color: theme.primaryAccentColor, width: theme.borderWidth),
                            ),
                            child: Text(
                              '${widget.speed.toInt()} KM/H',
                              style: theme.getHeaderTextStyle(
                                fontSize: size * 0.08,
                                color: _getSpeedCriticalityColor(theme),
                              ),
                            ),
                          ),
                        ),
                    ],
                    // RPM indicator (original position for Linux theme)
                    Positioned(
                      bottom: size * 0.15,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: size * 0.06, vertical: size * 0.02),
                        decoration: BoxDecoration(
                          color: theme.containerColor,
                          borderRadius: BorderRadius.circular(theme.borderRadius),
                          border: Border.all(color: theme.tachometerColor, width: theme.borderWidth),
                        ),
                        child: Text(
                          '${(widget.rpm / 1000).toStringAsFixed(1)}K RPM',
                          style: theme.getBodyTextStyle(fontSize: size * 0.045, color: theme.tachometerColor),
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
                          child: GestureDetector(
                            onTap: () => dashboardState.toggleDemoMode(),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: size * 0.04, vertical: size * 0.02),
                              decoration: BoxDecoration(
                                color: dashboardState.demoMode ? theme.dangerColor : theme.successColor,
                                borderRadius: BorderRadius.circular(theme.borderRadius + 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: theme.shadowBlurRadius,
                                    offset: theme.shadowOffset,
                                  ),
                                ],
                              ),
                              child: Text(
                                dashboardState.demoMode ? 'STOP' : 'DEMO',
                                style: theme.getHeaderTextStyle(fontSize: size * 0.035, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Stop button - always visible during demo
                    if (dashboardState.demoMode)
                      Positioned(
                        bottom: size * 0.05,
                        left: size * 0.05,
                        child: GestureDetector(
                          onTap: () => dashboardState.toggleDemoMode(),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: size * 0.04, vertical: size * 0.02),
                            decoration: BoxDecoration(
                              color: theme.dangerColor,
                              borderRadius: BorderRadius.circular(theme.borderRadius + 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: theme.shadowBlurRadius,
                                  offset: theme.shadowOffset,
                                ),
                              ],
                            ),
                            child: Text(
                              'STOP',
                              style: theme.getHeaderTextStyle(fontSize: size * 0.035, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Get speed criticality color based on speed value
  Color _getSpeedCriticalityColor(DashboardTheme theme) {
    if (widget.speed <= 50) {
      return theme.successColor; // Low speed - green
    } else if (widget.speed <= 80) {
      return theme.primaryAccentColor; // Normal speed - blue
    } else if (widget.speed <= 120) {
      return theme.warningColor; // High speed - orange
    } else {
      return theme.dangerColor; // Very high speed - red
    }
  }
}
