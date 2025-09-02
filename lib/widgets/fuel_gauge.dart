import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../services/dashboard_state.dart';
import '../themes/dashboard_theme.dart';
import 'dynamic_gauge_painter.dart';
import 'themed/themed_widget_interface.dart';
import 'themed/analog_needle_gauge.dart';

class FuelGauge extends StatelessWidget with MultiThemedWidget {
  final double fuelLevel;
  static const double maxFuel = 100.0;
  static const double lowFuelThreshold = 15.0;

  const FuelGauge({super.key, required this.fuelLevel});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardState>(
      builder: (context, dashboardState, child) {
        final theme = dashboardState.currentTheme;
        return buildForTheme(context, theme);
      },
    );
  }

  Widget _buildOriginalLayout(BuildContext context) {
    return Consumer<DashboardState>(
      builder: (context, dashboardState, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = dashboardState.isSmallScreen;

            // Check if this section needs small screen mode
            final needsSmallScreen = _checkIfNeedsSmallScreen(constraints);

            // Notify state manager
            if (needsSmallScreen && !isSmallScreen) {
              // Use post-frame callback to avoid build-time state changes
              WidgetsBinding.instance.addPostFrameCallback((_) {
                dashboardState.requestSmallScreenMode('FuelGauge');
              });
            } else if (!needsSmallScreen && isSmallScreen) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                dashboardState.requestBigScreenMode('FuelGauge');
              });
            }

            final theme = dashboardState.currentTheme;

            return Container(
              padding: EdgeInsets.all(theme.containerPadding.top * 0.5),
              decoration: theme.getContainerDecoration(),
              child: Stack(
                children: [
                  // Floating icon for small screens
                  if (isSmallScreen)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Icon(Icons.local_gas_station, color: theme.primaryAccentColor, size: theme.iconSize),
                    ),

                  Column(
                    children: [
                      // Header (only show on normal screens)
                      if (!isSmallScreen) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_gas_station, color: theme.primaryAccentColor, size: theme.iconSize),
                            SizedBox(width: theme.borderRadius * 0.5),
                            Text('FUEL LEVEL', style: theme.getHeaderTextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Gauge - fill available space
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
                                    // Dynamic gauge based on theme
                                    CustomPaint(
                                      size: Size(gaugeSize, gaugeSize),
                                      painter: DynamicGaugePainter(
                                        value: fuelLevel,
                                        minValue: 0.0,
                                        maxValue: maxFuel,
                                        theme: theme,
                                        label: 'FUEL',
                                        unit: '%',
                                      ),
                                    ),

                                    // Fuel level display
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${fuelLevel.toInt()}%',
                                          style: GoogleFonts.orbitron(
                                            color: theme.getFuelColor(fuelLevel),
                                            fontSize: gaugeSize * 0.2,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (!isSmallScreen)
                                          Text('FUEL', style: theme.getBodyTextStyle(fontSize: gaugeSize * 0.07)),
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
                value: fuelLevel,
                minValue: 0.0,
                maxValue: maxFuel,
                label: 'FUEL',
                unit: '%',
                needleColor: theme.primaryAccentColor,
                backgroundColor: theme.backgroundColor,
                tickColor: theme.textSecondaryColor,
                textColor: theme.textPrimaryColor,
                tickLabels: ['E', '1/4', '1/2', '3/4', 'F'],
                criticalityColorFunction: (value) {
                  if (value <= 10) {
                    return theme.dangerColor; // Critical - red
                  } else if (value <= 25) {
                    return theme.warningColor; // Low - orange
                  } else if (value <= 50) {
                    return theme.primaryAccentColor; // Medium - blue
                  } else {
                    return theme.successColor; // Good - green
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
          // Use post-frame callback to avoid build-time state changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            dashboardState.requestSmallScreenMode('FuelGauge');
          });
        } else if (!needsSmallScreen && isSmallScreen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            dashboardState.requestBigScreenMode('FuelGauge');
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
                  child: Text('FUEL', style: theme.getHeaderTextStyle(fontSize: 10), textAlign: TextAlign.center),
                ),
              // Gauge
              Center(
                child: CustomPaint(
                  size: Size(constraints.maxWidth * 0.8, constraints.maxHeight * 0.8),
                  painter: DynamicGaugePainter(
                    value: fuelLevel,
                    minValue: 0.0,
                    maxValue: maxFuel,
                    label: 'FUEL',
                    unit: '%',
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
                    '${fuelLevel.toInt()}%',
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
  Widget buildWoman(BuildContext context, DashboardTheme theme) {
    return Container(
      padding: EdgeInsets.all(theme.containerPadding.top * 0.5),
      decoration: theme.getContainerDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gaugeSize = math.min(constraints.maxWidth, constraints.maxHeight) * 0.9;
          return Center(
            child: SizedBox(
              width: gaugeSize,
              height: gaugeSize,
              child: AnalogNeedleGauge(
                value: fuelLevel,
                minValue: 0.0,
                maxValue: maxFuel,
                label: 'FUEL',
                unit: '%',
                needleColor: theme.primaryAccentColor,
                backgroundColor: theme.backgroundColor,
                tickColor: theme.textSecondaryColor,
                textColor: theme.textPrimaryColor,
                tickLabels: ['E', '1/4', '1/2', '3/4', 'F'],
                criticalityColorFunction: (value) {
                  if (value <= 10) {
                    return theme.dangerColor; // Critical - red
                  } else if (value <= 25) {
                    return theme.warningColor; // Low - orange
                  } else if (value <= 50) {
                    return theme.primaryAccentColor; // Medium - blue
                  } else {
                    return theme.successColor; // Good - green
                  }
                },
              ),
            ),
          );
        },
      ),
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
          // Use post-frame callback to avoid build-time state changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            dashboardState.requestSmallScreenMode('FuelGauge');
          });
        } else if (!needsSmallScreen && isSmallScreen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            dashboardState.requestBigScreenMode('FuelGauge');
          });
        }

        return Container(
          padding: EdgeInsets.all(theme.containerPadding.top * 0.5),
          decoration: theme.getContainerDecoration(),
          child: Stack(
            children: [
              if (isSmallScreen)
                Positioned(
                  child: Icon(Icons.local_gas_station, color: theme.primaryAccentColor, size: theme.iconSize),
                ),
              Column(
                children: [
                  if (!isSmallScreen) ...[
                    Row(
                      children: [
                        Icon(Icons.local_gas_station, color: theme.primaryAccentColor, size: theme.iconSize),
                        SizedBox(width: theme.borderRadius * 0.5),
                        Text('FUEL LEVEL', style: theme.getHeaderTextStyle(fontSize: 12)),
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
                                    value: fuelLevel,
                                    minValue: 0.0,
                                    maxValue: maxFuel,
                                    theme: theme,
                                    label: 'FUEL',
                                    unit: '%',
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${fuelLevel.toInt()}%',
                                      style: GoogleFonts.orbitron(
                                        color: theme.getFuelColor(fuelLevel),
                                        fontSize: gaugeSize * 0.2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (!isSmallScreen)
                                      Text('FUEL', style: theme.getBodyTextStyle(fontSize: gaugeSize * 0.07)),
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
}

class FuelGaugePainter extends CustomPainter {
  final double fuelLevel;
  final DashboardTheme theme;

  const FuelGaugePainter({required this.fuelLevel, required this.theme});

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

    // Calculate current fuel level position
    final normalizedFuel = (fuelLevel / FuelGauge.maxFuel).clamp(0.0, 1.0);
    final currentTickIndex = (normalizedFuel * numTicks).round();

    // Get uniform color for all ticks based on current fuel level criticality
    final currentFuelColor = theme.getFuelColor(fuelLevel);

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

    // Low fuel warning indicator (special thick mark)
    if (fuelLevel <= FuelGauge.lowFuelThreshold) {
      final lowFuelAngle = -math.pi * 0.75 + (FuelGauge.lowFuelThreshold / FuelGauge.maxFuel) * math.pi * 1.5;

      paint.color = theme.dangerColor;
      paint.strokeWidth = 5;
      final warningStart =
          center + Offset(math.cos(lowFuelAngle) * (radius - 20), math.sin(lowFuelAngle) * (radius - 20));
      final warningEnd = center + Offset(math.cos(lowFuelAngle) * (radius + 5), math.sin(lowFuelAngle) * (radius + 5));

      canvas.drawLine(warningStart, warningEnd, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is FuelGaugePainter && (oldDelegate.fuelLevel != fuelLevel || oldDelegate.theme != theme);
  }
}
