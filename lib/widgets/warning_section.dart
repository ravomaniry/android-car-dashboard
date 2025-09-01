import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/bluetooth_service.dart';
import '../services/gps_service.dart';
import '../services/dashboard_state.dart';
import '../services/event_manager.dart';

class WarningSection extends StatefulWidget {
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
  State<WarningSection> createState() => _WarningSectionState();
}

class _WarningSectionState extends State<WarningSection> {
  StreamSubscription<BluetoothEvent>? _bluetoothEventSubscription;
  StreamSubscription<GpsEvent>? _gpsEventSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToEvents();
    _initializeDefaultEventsDelayed();
  }

  @override
  void dispose() {
    _bluetoothEventSubscription?.cancel();
    _gpsEventSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToEvents() {
    final eventManager = Provider.of<EventManager>(context, listen: false);

    // Subscribe to Bluetooth events
    _bluetoothEventSubscription = eventManager.bluetoothEventStream.listen((event) {
      if (mounted) {
        setState(() {});
      }
    });

    // Subscribe to GPS events
    _gpsEventSubscription = eventManager.gpsEventStream.listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  // Initialize with some default events
  void _initializeDefaultEvents() {
    final eventManager = Provider.of<EventManager>(context, listen: false);

    // Add initial Bluetooth events
    eventManager.addBluetoothEvent('Bluetooth Service initialized', 'INFO');
    eventManager.addBluetoothEvent('Target device: RAVO_CAR_DASH', 'CONFIG');
    eventManager.addBluetoothEvent('Scanning for devices...', 'INFO');
    eventManager.addBluetoothEvent('Device found: RAVO_CAR_DASH', 'INFO');
    eventManager.addBluetoothEvent('Attempting connection...', 'INFO');
    eventManager.addBluetoothEvent('Connection established', 'STATUS');
    eventManager.addBluetoothEvent('Authentication successful', 'STATUS');
    eventManager.addBluetoothEvent('Receiving data: coolant temp 82°C', 'DATA');
    eventManager.addBluetoothEvent('Receiving data: fuel level 65%', 'DATA');
    eventManager.addBluetoothEvent('Connection active', 'STATUS');

    // Add initial GPS events
    eventManager.addGpsEvent('GPS Service initialized', 'INFO');
    eventManager.addGpsEvent('Location permission: Checking...', 'STATUS');
    eventManager.addGpsEvent('GPS tracking started', 'INFO');
    eventManager.addGpsEvent('Location acquired: Stationary', 'DATA');
    eventManager.addGpsEvent('Speed update: 0.0 km/h', 'DATA');
    eventManager.addGpsEvent('GPS accuracy: High', 'STATUS');
    eventManager.addGpsEvent('Tracking status: Active', 'STATUS');
    eventManager.addGpsEvent('No active trip', 'STATUS');
    eventManager.addGpsEvent('Waiting for movement...', 'STATUS');
    eventManager.addGpsEvent('GPS ready for tracking', 'STATUS');
  }

  // Call this after a delay to initialize default events
  void _initializeDefaultEventsDelayed() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _initializeDefaultEvents();
      }
    });
  }

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
            Expanded(child: _buildSmallWarningItem('OIL', widget.oilWarning, Icons.opacity)),
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
        _buildWarningItem('OIL', widget.oilWarning, Icons.opacity, 'PRESSURE OK', 'LOW PRESSURE'),
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
          animation: widget.blinkAnimation,
          builder: (context, child) {
            return Icon(
              icon,
              color: isWarning
                  ? Color.lerp(Colors.red.withOpacity(0.3), Colors.red, widget.blinkAnimation.value)
                  : const Color(0xFF00FF41),
              size: 24,
            );
          },
        ),
      ),
    );
  }

  Widget _buildSmallBatteryItem() {
    bool isLowVoltage = widget.batteryVoltage > 0 && widget.batteryVoltage < 12.0;
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
          animation: widget.blinkAnimation,
          builder: (context, child) {
            Color iconColor = isLowVoltage
                ? Color.lerp(Colors.red.withOpacity(0.3), Colors.red, widget.blinkAnimation.value)!
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

        return GestureDetector(
          onTap: () {
            _showBluetoothDialog(context);
          },
          child: Container(
            height: 60,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: isWarning ? Colors.red : const Color(0xFF333333), width: 1),
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: widget.blinkAnimation,
                builder: (context, child) {
                  return Icon(
                    Icons.bluetooth,
                    color: isWarning
                        ? Color.lerp(Colors.red.withOpacity(0.3), Colors.red, widget.blinkAnimation.value)
                        : const Color(0xFF00FF41),
                    size: 24,
                  );
                },
              ),
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

        return GestureDetector(
          onTap: () {
            _showGpsDialog(context);
          },
          child: Container(
            height: 60,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: isWarning ? Colors.red : const Color(0xFF333333), width: 1),
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: widget.blinkAnimation,
                builder: (context, child) {
                  return Icon(
                    Icons.gps_fixed,
                    color: isWarning
                        ? Color.lerp(Colors.red.withOpacity(0.3), Colors.red, widget.blinkAnimation.value)
                        : const Color(0xFF00FF41),
                    size: 24,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBatteryItem() {
    // Determine battery status based on voltage
    bool isLowVoltage = widget.batteryVoltage > 0 && widget.batteryVoltage < 12.0;
    Color voltageColor = isLowVoltage ? Colors.red : const Color(0xFF00FF41);
    String voltageText = widget.batteryVoltage > 0 ? '${widget.batteryVoltage.toStringAsFixed(1)}V' : '0.0V';

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
            animation: widget.blinkAnimation,
            builder: (context, child) {
              Color iconColor = isLowVoltage
                  ? Color.lerp(Colors.red.withOpacity(0.3), Colors.red, widget.blinkAnimation.value)!
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

        return GestureDetector(
          onTap: () {
            // Show Bluetooth dialog
            _showBluetoothDialog(context);
          },
          child: Container(
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
                  animation: widget.blinkAnimation,
                  builder: (context, child) {
                    return Icon(
                      Icons.bluetooth,
                      color: isWarning
                          ? Color.lerp(Colors.red.withOpacity(0.3), Colors.red, widget.blinkAnimation.value)
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
                        style: GoogleFonts.firaCode(
                          color: isWarning ? Colors.red : const Color(0xFF888888),
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isWarning)
                  AnimatedBuilder(
                    animation: widget.blinkAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color.lerp(Colors.red.withOpacity(0.3), Colors.red, widget.blinkAnimation.value),
                          shape: BoxShape.circle,
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

  Widget _buildGpsWarningItem() {
    return Consumer<GpsService>(
      builder: (context, gpsService, child) {
        final isTracking = gpsService.isTracking;
        final hasPermission = gpsService.hasLocationPermission;

        bool isWarning = !hasPermission || !isTracking;

        return GestureDetector(
          onTap: () {
            // Show GPS dialog
            _showGpsDialog(context);
          },
          child: Container(
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
                  animation: widget.blinkAnimation,
                  builder: (context, child) {
                    return Icon(
                      Icons.gps_fixed,
                      color: isWarning
                          ? Color.lerp(Colors.red.withOpacity(0.3), Colors.red, widget.blinkAnimation.value)
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
                        style: GoogleFonts.firaCode(
                          color: isWarning ? Colors.red : const Color(0xFF888888),
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isWarning)
                  AnimatedBuilder(
                    animation: widget.blinkAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color.lerp(Colors.red.withOpacity(0.3), Colors.red, widget.blinkAnimation.value),
                          shape: BoxShape.circle,
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
            animation: widget.blinkAnimation,
            builder: (context, child) {
              return Icon(
                icon,
                color: isWarning
                    ? Color.lerp(Colors.red.withOpacity(0.3), Colors.red, widget.blinkAnimation.value)
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
              animation: widget.blinkAnimation,
              builder: (context, child) {
                return Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Color.lerp(Colors.red.withOpacity(0.3), Colors.red, widget.blinkAnimation.value),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showBluetoothDialog(BuildContext context) {
    // Import and use the ServiceDialogs
    // Since we can't import here, we'll use a simple approach
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<BluetoothService>(
          builder: (context, bluetoothService, child) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: Row(
                children: [
                  Icon(Icons.bluetooth, color: const Color(0xFF00D9FF)),
                  const SizedBox(width: 8),
                  Text(
                    'Bluetooth Service',
                    style: GoogleFonts.firaCode(
                      color: const Color(0xFF00D9FF),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 500,
                height: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status section with events
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F0F0F),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF00D9FF), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  bluetoothService.isAuthenticated ? Icons.bluetooth_connected : Icons.bluetooth,
                                  color: bluetoothService.isAuthenticated
                                      ? const Color(0xFF00FF41)
                                      : const Color(0xFFFF5722),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Bluetooth Status',
                                  style: GoogleFonts.firaCode(
                                    color: const Color(0xFF00D9FF),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bluetoothService.status,
                              style: GoogleFonts.firaCode(color: Colors.white, fontSize: 12),
                            ),
                            const SizedBox(height: 16),

                            // Latest events section
                            Text(
                              'Latest Events (10):',
                              style: GoogleFonts.firaCode(
                                color: const Color(0xFF00D9FF),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF000000),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Consumer<EventManager>(
                                  builder: (context, eventManager, child) {
                                    final events = eventManager.latestBluetoothEvents;
                                    return SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: events
                                            .map(
                                              (event) => _buildEventEntry(event.message, event.level, event.timestamp),
                                            )
                                            .toList(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Control buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: bluetoothService.isConnecting
                                ? null
                                : () {
                                    if (bluetoothService.isAuthenticated) {
                                      bluetoothService.disconnect();
                                    } else {
                                      bluetoothService.connectToDevice();
                                    }
                                  },
                            icon: Icon(
                              bluetoothService.isAuthenticated ? Icons.bluetooth_disabled : Icons.bluetooth,
                              color: Colors.white,
                            ),
                            label: Text(
                              bluetoothService.isAuthenticated ? 'Disconnect' : 'Connect',
                              style: GoogleFonts.firaCode(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: bluetoothService.isAuthenticated
                                  ? const Color(0xFFFF5722)
                                  : const Color(0xFF00FF41),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: bluetoothService.isConnecting ? null : () => bluetoothService.retryConnection(),
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            label: Text('Retry', style: GoogleFonts.firaCode(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9800),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Close', style: GoogleFonts.firaCode(color: const Color(0xFF00D9FF))),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showGpsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<GpsService>(
          builder: (context, gpsService, child) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: Row(
                children: [
                  Icon(Icons.gps_fixed, color: const Color(0xFF00D9FF)),
                  const SizedBox(width: 8),
                  Text(
                    'GPS Service',
                    style: GoogleFonts.firaCode(
                      color: const Color(0xFF00D9FF),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 500,
                height: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status section with events
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F0F0F),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF00D9FF), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  gpsService.isTracking ? Icons.gps_fixed : Icons.gps_not_fixed,
                                  color: gpsService.isTracking ? const Color(0xFF00FF41) : const Color(0xFFFF5722),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'GPS Status',
                                  style: GoogleFonts.firaCode(
                                    color: const Color(0xFF00D9FF),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(gpsService.status, style: GoogleFonts.firaCode(color: Colors.white, fontSize: 12)),
                            const SizedBox(height: 16),

                            // Latest events section
                            Text(
                              'Latest Events (10):',
                              style: GoogleFonts.firaCode(
                                color: const Color(0xFF00D9FF),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF000000),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Consumer<EventManager>(
                                  builder: (context, eventManager, child) {
                                    final events = eventManager.latestGpsEvents;
                                    return SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: events
                                            .map(
                                              (event) => _buildEventEntry(event.message, event.level, event.timestamp),
                                            )
                                            .toList(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Test and Close buttons in same row
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final position = await gpsService.getCurrentLocation();
                              // Location test completed silently - no popup messages
                            },
                            icon: const Icon(Icons.location_on, color: Colors.white),
                            label: Text('Test Location', style: GoogleFonts.firaCode(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00D9FF),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Close', style: GoogleFonts.firaCode(color: const Color(0xFF00D9FF))),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventEntry(String message, String level, DateTime timestamp) {
    Color levelColor;
    switch (level) {
      case 'INFO':
        levelColor = const Color(0xFF00D9FF);
        break;
      case 'STATUS':
        levelColor = const Color(0xFF00FF41);
        break;
      case 'CONFIG':
        levelColor = const Color(0xFFFF9800);
        break;
      case 'TRIP':
        levelColor = const Color(0xFFE91E63);
        break;
      case 'DATA':
        levelColor = const Color(0xFF9C27B0);
        break;
      case 'ERROR':
        levelColor = const Color(0xFFFF5722);
        break;
      default:
        levelColor = const Color(0xFF888888);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: levelColor.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
            child: Text(
              level,
              style: GoogleFonts.firaCode(color: levelColor, fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: GoogleFonts.firaCode(color: Colors.white, fontSize: 10)),
          ),
          const SizedBox(width: 8),
          Text(
            '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
            style: GoogleFonts.firaCode(color: const Color(0xFF666666), fontSize: 8),
          ),
        ],
      ),
    );
  }
}
