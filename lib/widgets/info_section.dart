import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import '../services/gps_service.dart';
import '../services/dashboard_state.dart';

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
                  BoxShadow(color: const Color(0xFF00FF41).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.info_outline, color: const Color(0xFF00FF41), size: 16),
              const SizedBox(width: 8),
              Text(
                'VEHICLE STATUS',
                style: GoogleFonts.firaCode(color: const Color(0xFF00FF41), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lighting section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LIGHTING SYSTEMS',
                  style: GoogleFonts.firaCode(
                    color: const Color(0xFF888888),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Light indicators in a row
                Row(
                  children: [
                    Expanded(
                      child: _buildLightIndicator('DRL', 'Daytime Running Lights', Icons.wb_sunny, drlOn, false),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildLightIndicator(
                        'LOW',
                        'Low Beam Headlights',
                        Icons.lightbulb_outline,
                        lowBeamOn,
                        false,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildLightIndicator('HIGH', 'High Beam Headlights', Icons.highlight, highBeamOn, false),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  'SIGNAL INDICATORS',
                  style: GoogleFonts.firaCode(
                    color: const Color(0xFF888888),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Turn signals in a row (L - HAZ - R)
                Row(
                  children: [
                    Expanded(
                      child: _buildSignalIndicator(
                        'L',
                        'Left Turn',
                        Icons.keyboard_arrow_left,
                        leftTurnSignal || hazardLights,
                        leftTurnSignal || hazardLights,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSignalIndicator('HAZ', 'Hazard Lights', Icons.warning, hazardLights, hazardLights),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSignalIndicator(
                        'R',
                        'Right Turn',
                        Icons.keyboard_arrow_right,
                        rightTurnSignal || hazardLights,
                        rightTurnSignal || hazardLights,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallScreenLayout() {
    return Container(
      padding: const EdgeInsets.all(8), // Reduced padding for small screen
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF00FF41), width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00FF41).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact lighting section - no titles, just indicators
          Expanded(
            child: Column(
              children: [
                // Light indicators in a row - compact
                Row(
                  children: [
                    Expanded(child: _buildCompactLightIndicator('DRL', Icons.wb_sunny, drlOn)),
                    const SizedBox(width: 4),
                    Expanded(child: _buildCompactLightIndicator('LOW', Icons.lightbulb_outline, lowBeamOn)),
                    const SizedBox(width: 4),
                    Expanded(child: _buildCompactLightIndicator('HIGH', Icons.highlight, highBeamOn)),
                  ],
                ),

                const SizedBox(height: 8),

                // Turn signals in a row - compact
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactSignalIndicator(
                        'L',
                        Icons.keyboard_arrow_left,
                        leftTurnSignal || hazardLights,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(child: _buildCompactSignalIndicator('HAZ', Icons.warning, hazardLights)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildCompactSignalIndicator(
                        'R',
                        Icons.keyboard_arrow_right,
                        rightTurnSignal || hazardLights,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLightIndicator(String label, String description, IconData icon, bool isOn, bool shouldBlink) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isOn ? const Color(0xFF00FF41) : const Color(0xFF333333), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: blinkAnimation,
            builder: (context, child) {
              final color = isOn
                  ? (shouldBlink
                        ? Color.lerp(
                            const Color(0xFF00FF41).withOpacity(0.3),
                            const Color(0xFF00FF41),
                            blinkAnimation.value,
                          )
                        : const Color(0xFF00FF41))
                  : const Color(0xFF333333);

              return Icon(icon, color: color, size: 14);
            },
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.firaCode(
                color: isOn ? const Color(0xFF00FF41) : const Color(0xFF666666),
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              isOn ? 'ON' : 'OFF',
              style: GoogleFonts.firaCode(color: isOn ? const Color(0xFF888888) : const Color(0xFF444444), fontSize: 6),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLightIndicator(String label, IconData icon, bool isOn) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isOn ? const Color(0xFF00FF41) : const Color(0xFF333333), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isOn ? const Color(0xFF00FF41) : const Color(0xFF333333), size: 12),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.firaCode(
                color: isOn ? const Color(0xFF00FF41) : const Color(0xFF666666),
                fontSize: 6,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              isOn ? 'ON' : 'OFF',
              style: GoogleFonts.firaCode(color: isOn ? const Color(0xFF888888) : const Color(0xFF444444), fontSize: 4),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalIndicator(String label, String description, IconData icon, bool isOn, bool shouldBlink) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isOn ? Colors.orange : const Color(0xFF333333), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: blinkAnimation,
            builder: (context, child) {
              final color = isOn
                  ? (shouldBlink
                        ? Color.lerp(Colors.orange.withOpacity(0.3), Colors.orange, blinkAnimation.value)
                        : Colors.orange)
                  : const Color(0xFF333333);

              return Icon(icon, color: color, size: 16);
            },
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.firaCode(
                color: isOn ? Colors.orange : const Color(0xFF666666),
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSignalIndicator(String label, IconData icon, bool isOn) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isOn ? Colors.orange : const Color(0xFF333333), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isOn ? Colors.orange : const Color(0xFF333333), size: 12),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.firaCode(
                color: isOn ? Colors.orange : const Color(0xFF666666),
                fontSize: 6,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothStatus() {
    return Consumer<BluetoothService>(
      builder: (context, bluetoothService, child) {
        Color statusColor;
        String statusText;
        IconData statusIcon;

        if (bluetoothService.isAuthenticated) {
          statusColor = const Color(0xFFFF5722); // Red for disconnect
          statusText = 'DISCONNECT';
          statusIcon = Icons.bluetooth_disabled;
        } else if (bluetoothService.isConnecting) {
          statusColor = const Color(0xFF00D9FF); // Cyan for connecting
          statusText = 'CONNECTING';
          statusIcon = Icons.bluetooth_searching;
        } else {
          statusColor = const Color(0xFF00D9FF); // Blue for connect
          statusText = 'CONNECT';
          statusIcon = Icons.bluetooth;
        }

        return GestureDetector(
          onTap: bluetoothService.isConnecting
              ? null
              : () {
                  if (bluetoothService.isAuthenticated) {
                    bluetoothService.disconnect();
                  } else {
                    bluetoothService.connectToDevice();
                  }
                },
          child: Container(
            height: 60,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              border: Border.all(color: statusColor, width: 1),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: statusColor.withOpacity(0.1), blurRadius: 8)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    'BLUETOOTH',
                    style: GoogleFonts.firaCode(
                      color: const Color(0xFF888888),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    statusText,
                    style: GoogleFonts.firaCode(color: statusColor, fontSize: 8, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGpsStatus() {
    return Consumer<GpsService>(
      builder: (context, gpsService, child) {
        Color statusColor;
        String statusText;
        IconData statusIcon;

        if (gpsService.isTracking) {
          statusColor = const Color(0xFF00FF41); // Green for stop tracking
          statusText = 'STOP GPS';
          statusIcon = Icons.gps_fixed;
        } else if (gpsService.hasLocationPermission) {
          statusColor = const Color(0xFF00D9FF); // Cyan for start tracking
          statusText = 'START GPS';
          statusIcon = Icons.gps_not_fixed;
        } else {
          statusColor = const Color(0xFF666666); // Gray for disabled
          statusText = 'DISABLED';
          statusIcon = Icons.gps_off;
        }

        return GestureDetector(
          onTap: gpsService.hasLocationPermission
              ? () {
                  if (gpsService.isTracking) {
                    gpsService.stopTracking();
                  } else {
                    gpsService.startTracking();
                  }
                }
              : null,
          child: Container(
            height: 60,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              border: Border.all(color: statusColor, width: 1),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: statusColor.withOpacity(0.1), blurRadius: 8)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    'GPS',
                    style: GoogleFonts.firaCode(
                      color: const Color(0xFF888888),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    statusText,
                    style: GoogleFonts.firaCode(color: statusColor, fontSize: 8, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactGpsStatus() {
    return Consumer<GpsService>(
      builder: (context, gpsService, child) {
        Color statusColor;
        String statusText;
        IconData statusIcon;

        if (gpsService.isTracking) {
          statusColor = const Color(0xFF00FF41); // Green for stop tracking
          statusText = 'STOP GPS';
          statusIcon = Icons.gps_fixed;
        } else if (gpsService.hasLocationPermission) {
          statusColor = const Color(0xFF00D9FF); // Cyan for start tracking
          statusText = 'START GPS';
          statusIcon = Icons.gps_not_fixed;
        } else {
          statusColor = const Color(0xFF666666); // Gray for disabled
          statusText = 'DISABLED';
          statusIcon = Icons.gps_off;
        }

        return GestureDetector(
          onTap: gpsService.hasLocationPermission
              ? () {
                  if (gpsService.isTracking) {
                    gpsService.stopTracking();
                  } else {
                    gpsService.startTracking();
                  }
                }
              : null,
          child: Container(
            height: 40,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              border: Border.all(color: statusColor, width: 1),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [BoxShadow(color: statusColor.withOpacity(0.1), blurRadius: 4)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 12),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    'GPS',
                    style: GoogleFonts.firaCode(
                      color: const Color(0xFF888888),
                      fontSize: 6,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    statusText,
                    style: GoogleFonts.firaCode(color: statusColor, fontSize: 6, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
