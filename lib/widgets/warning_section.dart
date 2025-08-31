import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import '../services/gps_service.dart';
import '../services/dashboard_state.dart';

class WarningSection extends StatelessWidget {
  final bool oilWarning;
  final double batteryVoltage;
  final Animation<double> blinkAnimation;

  const WarningSection({
    super.key,
    required this.oilWarning,
    required this.batteryVoltage,
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
                dashboardState.requestSmallScreenMode('WarningSection');
              });
            } else if (!needsSmallScreen && isSmallScreen) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                dashboardState.requestBigScreenMode('WarningSection');
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
                        Icon(Icons.terminal, color: const Color(0xFF00FF41), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'SYSTEM STATUS',
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

                  // Warning indicators
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

  Widget _buildSmallScreenLayout() {
    return Column(
      children: [
        // Top row: Oil and Battery
        Row(
          children: [
            Expanded(child: _buildSmallWarningItem('OIL', oilWarning, Icons.opacity)),
            const SizedBox(width: 8),
            Expanded(child: _buildSmallBatteryItem()),
          ],
        ),
        const SizedBox(height: 8),
        // Bottom row: Bluetooth and GPS
        Row(
          children: [
            Expanded(child: _buildSmallBluetoothWarning()),
            const SizedBox(width: 8),
            Expanded(child: _buildSmallGpsWarning()),
          ],
        ),
      ],
    );
  }

  Widget _buildNormalLayout() {
    return Column(
      children: [
        _buildWarningItem('OIL', oilWarning, Icons.opacity, 'PRESSURE OK', 'LOW PRESSURE'),
        const SizedBox(height: 12),
        _buildBatteryItem(),
        const SizedBox(height: 12),
        _buildBluetoothWarningItem(),
        const SizedBox(height: 12),
        _buildGpsWarningItem(),
      ],
    );
  }

  Widget _buildSmallWarningItem(String label, bool isWarning, IconData icon) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isWarning ? Colors.red : const Color(0xFF333333), width: 1),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: blinkAnimation,
          builder: (context, child) {
            return Icon(
              icon,
              color: isWarning
                  ? Color.lerp(Colors.red.withOpacity(0.3), Colors.red, blinkAnimation.value)
                  : const Color(0xFF00FF41),
              size: 24,
            );
          },
        ),
      ),
    );
  }

  Widget _buildSmallBatteryItem() {
    bool isLowVoltage = batteryVoltage > 0 && batteryVoltage < 12.0;
    Color voltageColor = isLowVoltage ? Colors.red : const Color(0xFF00FF41);

    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: isLowVoltage ? Colors.red : const Color(0xFF333333), width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: voltageColor.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: blinkAnimation,
          builder: (context, child) {
            Color iconColor = isLowVoltage
                ? Color.lerp(Colors.red.withOpacity(0.3), Colors.red, blinkAnimation.value)!
                : voltageColor;

            return Icon(isLowVoltage ? Icons.battery_alert : Icons.battery_full, color: iconColor, size: 24);
          },
        ),
      ),
    );
  }

  Widget _buildSmallBluetoothWarning() {
    return Consumer<BluetoothService>(
      builder: (context, bluetoothService, child) {
        final isConnected = bluetoothService.isConnected;
        final isConnecting = bluetoothService.isConnecting;

        bool isWarning = !isConnected && !isConnecting;

        return Container(
          height: 60,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isWarning ? Colors.red : const Color(0xFF333333), width: 1),
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: blinkAnimation,
              builder: (context, child) {
                return Icon(
                  Icons.bluetooth,
                  color: isWarning
                      ? Color.lerp(Colors.red.withOpacity(0.3), Colors.red, blinkAnimation.value)
                      : const Color(0xFF00FF41),
                  size: 24,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmallGpsWarning() {
    return Consumer<GpsService>(
      builder: (context, gpsService, child) {
        final isTracking = gpsService.isTracking;
        final hasPermission = gpsService.hasLocationPermission;

        bool isWarning = !hasPermission || !isTracking;

        return Container(
          height: 60,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isWarning ? Colors.red : const Color(0xFF333333), width: 1),
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: blinkAnimation,
              builder: (context, child) {
                return Icon(
                  Icons.gps_fixed,
                  color: isWarning
                      ? Color.lerp(Colors.red.withOpacity(0.3), Colors.red, blinkAnimation.value)
                      : const Color(0xFF00FF41),
                  size: 24,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBatteryItem() {
    // Determine battery status based on voltage
    bool isLowVoltage = batteryVoltage > 0 && batteryVoltage < 12.0;
    Color voltageColor = isLowVoltage ? Colors.red : const Color(0xFF00FF41);
    String voltageText = batteryVoltage > 0 ? '${batteryVoltage.toStringAsFixed(1)}V' : '0.0V';

    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: isLowVoltage ? Colors.red : const Color(0xFF333333), width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: voltageColor.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: blinkAnimation,
            builder: (context, child) {
              Color iconColor = isLowVoltage
                  ? Color.lerp(Colors.red.withOpacity(0.3), Colors.red, blinkAnimation.value)!
                  : voltageColor;

              return Icon(isLowVoltage ? Icons.battery_alert : Icons.battery_full, color: iconColor, size: 20);
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'BATTERY',
                  style: GoogleFonts.firaCode(
                    color: const Color(0xFF888888),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  voltageText,
                  style: GoogleFonts.firaCode(color: voltageColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothWarningItem() {
    return Consumer<BluetoothService>(
      builder: (context, bluetoothService, child) {
        final isConnected = bluetoothService.isConnected;
        final isConnecting = bluetoothService.isConnecting;

        bool isWarning = !isConnected && !isConnecting;

        return Container(
          height: 60,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isWarning ? Colors.red : const Color(0xFF333333), width: 1),
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: blinkAnimation,
                builder: (context, child) {
                  return Icon(
                    Icons.bluetooth,
                    color: isWarning
                        ? Color.lerp(Colors.red.withOpacity(0.3), Colors.red, blinkAnimation.value)
                        : const Color(0xFF00FF41),
                    size: 16,
                  );
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'BLUETOOTH',
                      style: GoogleFonts.firaCode(
                        color: isWarning ? Colors.red : const Color(0xFF00FF41),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isWarning ? 'DISCONNECTED' : 'CONNECTED',
                      style: GoogleFonts.firaCode(color: isWarning ? Colors.red : const Color(0xFF888888), fontSize: 8),
                    ),
                  ],
                ),
              ),
              if (isWarning)
                AnimatedBuilder(
                  animation: blinkAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color.lerp(Colors.red.withOpacity(0.3), Colors.red, blinkAnimation.value),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGpsWarningItem() {
    return Consumer<GpsService>(
      builder: (context, gpsService, child) {
        final isTracking = gpsService.isTracking;
        final hasPermission = gpsService.hasLocationPermission;

        bool isWarning = !hasPermission || !isTracking;

        return Container(
          height: 60,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isWarning ? Colors.red : const Color(0xFF333333), width: 1),
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: blinkAnimation,
                builder: (context, child) {
                  return Icon(
                    Icons.gps_fixed,
                    color: isWarning
                        ? Color.lerp(Colors.red.withOpacity(0.3), Colors.red, blinkAnimation.value)
                        : const Color(0xFF00FF41),
                    size: 16,
                  );
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'GPS',
                      style: GoogleFonts.firaCode(
                        color: isWarning ? Colors.red : const Color(0xFF00FF41),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isWarning ? 'NOT TRACKING' : 'TRACKING',
                      style: GoogleFonts.firaCode(color: isWarning ? Colors.red : const Color(0xFF888888), fontSize: 8),
                    ),
                  ],
                ),
              ),
              if (isWarning)
                AnimatedBuilder(
                  animation: blinkAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color.lerp(Colors.red.withOpacity(0.3), Colors.red, blinkAnimation.value),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWarningItem(String label, bool isWarning, IconData icon, String okMessage, String warningMessage) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isWarning ? Colors.red : const Color(0xFF333333), width: 1),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: blinkAnimation,
            builder: (context, child) {
              return Icon(
                icon,
                color: isWarning
                    ? Color.lerp(Colors.red.withOpacity(0.3), Colors.red, blinkAnimation.value)
                    : const Color(0xFF00FF41),
                size: 16,
              );
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.firaCode(
                    color: isWarning ? Colors.red : const Color(0xFF00FF41),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isWarning ? warningMessage : okMessage,
                  style: GoogleFonts.firaCode(color: isWarning ? Colors.red : const Color(0xFF888888), fontSize: 8),
                ),
              ],
            ),
          ),
          if (isWarning)
            AnimatedBuilder(
              animation: blinkAnimation,
              builder: (context, child) {
                return Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Color.lerp(Colors.red.withOpacity(0.3), Colors.red, blinkAnimation.value),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
