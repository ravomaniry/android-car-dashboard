import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../services/dashboard_state.dart';
import '../themes/dashboard_theme.dart';
import 'dynamic_gauge_painter.dart';
import 'themed/themed_widget_interface.dart';
import 'themed/analog_needle_gauge.dart';

class CoolantGauge extends StatelessWidget with MultiThemedWidget {
  final double temperature;
  static const double minTemp = 60.0;
  static const double maxTemp = 120.0;
  static const double optimalTemp = 90.0;

  const CoolantGauge({super.key, required this.temperature});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardState>(
      builder: (context, dashboardState, child) {
        final theme = dashboardState.currentTheme;
        return buildForTheme(context, theme);
      },
    );
  }

  // Check if this section needs small screen mode based on available space
  bool _checkIfNeedsSmallScreen(BoxConstraints constraints) {
    final availableWidth = constraints.maxWidth;
    final availableHeight = constraints.maxHeight;

    // Use the same threshold as other sections (850px width)
    return availableWidth < 850 || availableHeight < 400;
  }

  @override
  Widget buildLinux(BuildContext context, DashboardTheme theme) {
    return _buildDefaultGauge(context, theme);
  }

  @override
  Widget buildClassic(BuildContext context, DashboardTheme theme) {
    return Container(
      padding: EdgeInsets.all(theme.containerPadding.top * 0.5),
      decoration: BoxDecoration(color: theme.backgroundColor, borderRadius: BorderRadius.circular(theme.borderRadius)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gaugeSize = math.min(constraints.maxWidth, constraints.maxHeight) * 0.9;
          return Center(
            child: SizedBox(
              width: gaugeSize,
              height: gaugeSize,
              child: AnalogNeedleGauge(
                value: temperature,
                minValue: minTemp,
                maxValue: maxTemp,
                label: 'TEMP',
                unit: '°C',
                needleColor: theme.primaryAccentColor,
                backgroundColor: theme.backgroundColor,
                tickColor: theme.textSecondaryColor,
                textColor: theme.textPrimaryColor,
                tickLabels: ['C', '70', '80', '90', 'H'],
                criticalityColorFunction: (value) {
                  if (value >= 100) {
                    return theme.dangerColor; // Overheating - red
                  } else if (value >= 90) {
                    return theme.warningColor; // Hot - orange
                  } else if (value >= 80) {
                    return theme.primaryAccentColor; // Normal high - blue
                  } else {
                    return theme.successColor; // Normal - green
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget buildModern(BuildContext context, DashboardTheme theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashboardState = context.read<DashboardState>();
        final isSmallScreen = dashboardState.isSmallScreen;

        // Check if this section needs small screen mode
        final needsSmallScreen = _checkIfNeedsSmallScreen(constraints);

        // Notify state manager
        if (needsSmallScreen && !isSmallScreen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            dashboardState.requestSmallScreenMode('CoolantGauge');
          });
        } else if (!needsSmallScreen && isSmallScreen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            dashboardState.requestBigScreenMode('CoolantGauge');
          });
        }

        return Container(
          padding: EdgeInsets.all(theme.containerPadding.top * 0.5),
          decoration: theme.getMetallicContainerDecoration(),
          child: Stack(
            children: [
              if (isSmallScreen)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Text('TEMP', style: theme.getHeaderTextStyle(fontSize: 10), textAlign: TextAlign.center),
                ),
              // Gauge
              Center(
                child: CustomPaint(
                  size: Size(constraints.maxWidth * 0.8, constraints.maxHeight * 0.8),
                  painter: DynamicGaugePainter(
                    value: temperature,
                    minValue: minTemp,
                    maxValue: maxTemp,
                    label: 'TEMP',
                    unit: '°C',
                    theme: theme,
                  ),
                ),
              ),
              // Value display
              if (!isSmallScreen)
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Text(
                    '${temperature.toInt()}°C',
                    style: theme.getHeaderTextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget buildTesla(BuildContext context, DashboardTheme theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashboardState = context.read<DashboardState>();
        final isSmallScreen = dashboardState.isSmallScreen;

        // Check if this section needs small screen mode
        final needsSmallScreen = _checkIfNeedsSmallScreen(constraints);

        // Notify state manager
        if (needsSmallScreen && !isSmallScreen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            dashboardState.requestSmallScreenMode('CoolantGauge');
          });
        } else if (!needsSmallScreen && isSmallScreen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            dashboardState.requestBigScreenMode('CoolantGauge');
          });
        }

        return Stack(
          children: [
            if (isSmallScreen)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Text('TEMP', style: theme.getHeaderTextStyle(fontSize: 10), textAlign: TextAlign.center),
              ),
            // Gauge with rounded background
            Center(
              child: Container(
                width: constraints.maxWidth * 0.8,
                height: constraints.maxHeight * 0.8,
                decoration: BoxDecoration(
                  color: theme.containerColor, // Gray background for circular gauge
                  shape: BoxShape.circle, // Circular background
                ),
                child: Stack(
                  children: [
                    // Gauge painter
                    CustomPaint(
                      size: Size(constraints.maxWidth * 0.8, constraints.maxHeight * 0.8),
                      painter: DynamicGaugePainter(
                        value: temperature,
                        minValue: minTemp,
                        maxValue: maxTemp,
                        label: 'TEMP',
                        unit: '°C',
                        theme: theme,
                      ),
                    ),
                    // Value display in center circle
                    Center(
                      child: Container(
                        width: constraints.maxWidth * 0.4,
                        height: constraints.maxHeight * 0.4,
                        decoration: BoxDecoration(
                          color: theme.backgroundColor.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.borderColor, width: theme.borderWidth),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              temperature.toInt().toString(),
                              style: theme.getHeaderTextStyle(
                                fontSize: constraints.maxWidth * 0.08,
                                color: _getTemperatureCriticalityColor(theme),
                              ),
                            ),
                            Text('°C', style: theme.getBodyTextStyle(fontSize: constraints.maxWidth * 0.03)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDefaultGauge(BuildContext context, DashboardTheme theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashboardState = context.read<DashboardState>();
        final isSmallScreen = dashboardState.isSmallScreen;

        // Check if this section needs small screen mode
        final needsSmallScreen = _checkIfNeedsSmallScreen(constraints);

        // Notify state manager
        if (needsSmallScreen && !isSmallScreen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            dashboardState.requestSmallScreenMode('CoolantGauge');
          });
        } else if (!needsSmallScreen && isSmallScreen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            dashboardState.requestBigScreenMode('CoolantGauge');
          });
        }

        return Container(
          padding: EdgeInsets.all(theme.containerPadding.top * 0.5),
          decoration: theme.getContainerDecoration(),
          child: Stack(
            children: [
              if (isSmallScreen)
                Positioned(
                  child: Icon(Icons.thermostat, color: theme.primaryAccentColor, size: theme.iconSize),
                ),
              Column(
                children: [
                  if (!isSmallScreen) ...[
                    Row(
                      children: [
                        Icon(Icons.thermostat, color: theme.primaryAccentColor, size: theme.iconSize),
                        SizedBox(width: theme.borderRadius * 0.5),
                        Text('COOLANT TEMP', style: theme.getHeaderTextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, gaugeConstraints) {
                        final gaugeSize = math.min(gaugeConstraints.maxWidth, gaugeConstraints.maxHeight) * 0.8;
                        return Center(
                          child: SizedBox(
                            width: gaugeSize,
                            height: gaugeSize,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: Size(gaugeSize, gaugeSize),
                                  painter: DynamicGaugePainter(
                                    value: temperature,
                                    minValue: minTemp,
                                    maxValue: maxTemp,
                                    theme: theme,
                                    label: 'TEMP',
                                    unit: '°C',
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${temperature.toInt()}°C',
                                      style: GoogleFonts.orbitron(
                                        color: theme.getTemperatureColor(temperature),
                                        fontSize: gaugeSize * 0.18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (!isSmallScreen)
                                      Text('TEMP', style: theme.getBodyTextStyle(fontSize: gaugeSize * 0.07)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getTemperatureCriticalityColor(DashboardTheme theme) {
    return theme.getTemperatureColor(temperature);
  }
}

class CoolantGaugePainter extends CustomPainter {
  final double temperature;
  final DashboardTheme theme;

  const CoolantGaugePainter({required this.temperature, required this.theme});

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
    paint.color = theme.inactiveColor;
    paint.strokeWidth = 2;
    canvas.drawCircle(center, radius, paint);

    // Calculate current temperature position
    final normalizedTemp = ((temperature - CoolantGauge.minTemp) / (CoolantGauge.maxTemp - CoolantGauge.minTemp)).clamp(
      0.0,
      1.0,
    );
    final currentTickIndex = (normalizedTemp * numTicks).round();

    // Get uniform color for all ticks based on current temperature criticality
    final currentTempColor = theme.getTemperatureColor(temperature);

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
        tickColor = theme.inactiveColor;
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is CoolantGaugePainter && (oldDelegate.temperature != temperature || oldDelegate.theme != theme);
  }
}
