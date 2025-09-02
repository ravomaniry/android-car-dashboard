import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/dashboard_state.dart';
import 'lighting_indicators.dart';
import 'signal_indicators.dart';

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

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                border: Border.all(color: const Color(0xFF00FF41), width: 1),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF41).withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  if (!isSmallScreen) ...[
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: const Color(0xFF00FF41), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'VEHICLE STATUS',
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
