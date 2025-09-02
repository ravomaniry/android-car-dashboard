import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/dashboard_state.dart';
import '../themes/dashboard_theme.dart';
import 'lighting_indicators.dart';
import 'signal_indicators.dart';

import 'themed/analog_light_indicator.dart';

class InfoSection extends StatelessWidget {
  final bool drlOn;
  final bool lowBeamOn;
  final bool highBeamOn;
  final bool leftTurnSignal;
  final bool rightTurnSignal;
  final bool hazardLights;
  final Animation<double> blinkAnimation;

  const InfoSection({
    super.key,
    required this.drlOn,
    required this.lowBeamOn,
    required this.highBeamOn,
    required this.leftTurnSignal,
    required this.rightTurnSignal,
    required this.hazardLights,
    required this.blinkAnimation,
  });

  @override
  Widget build(BuildContext context) {
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
                dashboardState.requestSmallScreenMode('InfoSection');
              });
            } else if (!needsSmallScreen && isSmallScreen) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                dashboardState.requestBigScreenMode('InfoSection');
              });
            }

            final theme = dashboardState.currentTheme;

            return Container(
              padding: theme.containerPadding,
              decoration: theme.gaugeStyle == GaugeStyle.analog
                  ? BoxDecoration(color: theme.backgroundColor, borderRadius: BorderRadius.circular(theme.borderRadius))
                  : theme.gaugeStyle == GaugeStyle.digital
                  ? theme.getMetallicContainerDecoration()
                  : theme.gaugeStyle == GaugeStyle.elegant
                  ? null // No background/border for Tesla theme
                  : theme.getContainerDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  if (!isSmallScreen) ...[
                    Row(
                      children: [
                        if (theme.gaugeStyle == GaugeStyle.analog)
                          AnalogLightIndicator(
                            isActive: true,
                            activeColor: theme.primaryAccentColor,
                            inactiveColor: theme.inactiveColor,
                            size: theme.iconSize * 1.2,
                            icon: Icons.info,
                          )
                        else if (theme.gaugeStyle == GaugeStyle.digital)
                          Icon(Icons.info_outline_rounded, color: theme.primaryAccentColor, size: theme.iconSize)
                        else
                          Icon(Icons.info_outline, color: theme.primaryAccentColor, size: theme.iconSize),
                        SizedBox(width: theme.borderRadius * 0.5),
                        Text('VEHICLE STATUS', style: theme.getHeaderTextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Content
                  Expanded(child: isSmallScreen ? _buildSmallScreenLayout() : _buildNormalLayout()),
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

  Widget _buildNormalLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lighting section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LightingIndicators(
                drlOn: drlOn,
                lowBeamOn: lowBeamOn,
                highBeamOn: highBeamOn,
                blinkAnimation: blinkAnimation,
                isCompact: false,
              ),
              const SizedBox(height: 16),
              SignalIndicators(
                leftTurnSignal: leftTurnSignal,
                rightTurnSignal: rightTurnSignal,
                hazardLights: hazardLights,
                blinkAnimation: blinkAnimation,
                isCompact: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallScreenLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Compact lighting section - no titles, just indicators
        Expanded(
          child: Column(
            children: [
              LightingIndicators(
                drlOn: drlOn,
                lowBeamOn: lowBeamOn,
                highBeamOn: highBeamOn,
                blinkAnimation: blinkAnimation,
                isCompact: true,
              ),
              const SizedBox(height: 8),
              SignalIndicators(
                leftTurnSignal: leftTurnSignal,
                rightTurnSignal: rightTurnSignal,
                hazardLights: hazardLights,
                blinkAnimation: blinkAnimation,
                isCompact: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
