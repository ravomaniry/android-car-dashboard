import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/dashboard_state.dart';
import '../services/event_manager.dart';
import '../themes/dashboard_theme.dart';
import 'oil_warning_indicator.dart';
import 'battery_indicator.dart';
import 'bluetooth_status_indicator.dart';
import 'gps_status_indicator.dart';

import 'themed/analog_light_indicator.dart';

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

            final theme = dashboardState.currentTheme;

            return Container(
              padding: theme.containerPadding,
              decoration: theme.gaugeStyle == GaugeStyle.analog
                  ? BoxDecoration(color: theme.backgroundColor, borderRadius: BorderRadius.circular(theme.borderRadius))
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
                            activeColor: theme.warningColor,
                            inactiveColor: theme.inactiveColor,
                            size: theme.iconSize * 1.2,
                            icon: Icons.warning,
                          )
                        else
                          Icon(Icons.terminal, color: theme.primaryAccentColor, size: theme.iconSize),
                        SizedBox(width: theme.borderRadius * 0.5),
                        Text('SYSTEM STATUS', style: theme.getHeaderTextStyle(fontSize: 12)),
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
            Expanded(
              child: OilWarningIndicator(
                oilWarning: widget.oilWarning,
                blinkAnimation: widget.blinkAnimation,
                isCompact: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: BatteryIndicator(
                batteryVoltage: widget.batteryVoltage,
                blinkAnimation: widget.blinkAnimation,
                isCompact: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Bottom row: Bluetooth and GPS
        Row(
          children: [
            Expanded(child: BluetoothStatusIndicator(blinkAnimation: widget.blinkAnimation, isCompact: true)),
            const SizedBox(width: 8),
            Expanded(child: GpsStatusIndicator(blinkAnimation: widget.blinkAnimation, isCompact: true)),
          ],
        ),
      ],
    );
  }

  Widget _buildNormalLayout() {
    return Column(
      children: [
        OilWarningIndicator(oilWarning: widget.oilWarning, blinkAnimation: widget.blinkAnimation, isCompact: false),
        const SizedBox(height: 12),
        BatteryIndicator(
          batteryVoltage: widget.batteryVoltage,
          blinkAnimation: widget.blinkAnimation,
          isCompact: false,
        ),
        const SizedBox(height: 12),
        BluetoothStatusIndicator(blinkAnimation: widget.blinkAnimation, isCompact: false),
        const SizedBox(height: 12),
        GpsStatusIndicator(blinkAnimation: widget.blinkAnimation, isCompact: false),
      ],
    );
  }
}
