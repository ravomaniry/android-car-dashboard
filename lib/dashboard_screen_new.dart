import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/dashboard_state.dart';
import 'services/bluetooth_service.dart';
import 'widgets/warning_section.dart';
import 'widgets/speedometer_widget.dart';
import 'widgets/trip_detail_item.dart';
import 'widgets/info_section.dart';
import 'widgets/coolant_gauge.dart';
import 'widgets/fuel_gauge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _blinkAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOut,
    ));
    _blinkController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Deep black background
      body: SafeArea(
        child: Consumer<DashboardState>(
          builder: (context, dashboardState, child) {
            final data = dashboardState.data;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // LEFT COLUMN - Warning and Coolant
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        // Warning Section
                        Expanded(
                          child: WarningSection(
                            oilWarning: data.oilWarning,
                            blinkAnimation: _blinkAnimation,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Coolant Temperature
                        Expanded(
                          child: CoolantGauge(temperature: data.coolantTemp),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // MIDDLE COLUMN - Speedometer and Trip Info
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        // Speedometer (takes most space)
                        Expanded(
                          flex: 3,
                          child: SpeedometerWidget(
                            speed: data.speed,
                            rpm: data.rpm,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Trip Details (bottom of middle column)
                        SizedBox(
                          height: 100,
                          child: Row(
                            children: [
                              Expanded(
                                child: TripDetailItem(
                                  label: 'DISTANCE',
                                  value: '${data.tripDistance.toStringAsFixed(1)} km',
                                  icon: Icons.straighten,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TripDetailItem(
                                  label: 'FUEL USE',
                                  value: '${data.fuelUsage.toStringAsFixed(1)} L/100km',
                                  icon: Icons.local_gas_station,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TripDetailItem(
                                  label: 'AVG TEMP',
                                  value: '${data.avgTemperature.toStringAsFixed(0)}°C',
                                  icon: Icons.thermostat,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TripDetailItem(
                                  label: 'AVG SPEED',
                                  value: '${data.avgSpeed.toStringAsFixed(1)} km/h',
                                  icon: Icons.speed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // RIGHT COLUMN - Vehicle Status and Fuel
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        // Vehicle Status/Info Section
                        Expanded(
                          child: InfoSection(
                            drlOn: data.drlOn,
                            lowBeamOn: data.lowBeamOn,
                            highBeamOn: data.highBeamOn,
                            leftTurnSignal: data.leftTurnSignal,
                            rightTurnSignal: data.rightTurnSignal,
                            hazardLights: data.hazardLights,
                            blinkAnimation: _blinkAnimation,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Fuel Level
                        Expanded(
                          child: FuelGauge(fuelLevel: data.fuelLevel),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: Consumer2<DashboardState, BluetoothService>(
        builder: (context, dashboardState, bluetoothService, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Connection Status Indicator
              if (!dashboardState.demoMode)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: bluetoothService.isAuthenticated ? const Color(0xFF00FF41) : const Color(0xFFFF5722),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    bluetoothService.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: 'FiraCode',
                    ),
                  ),
                ),
              const SizedBox(height: 8),

              // Bluetooth Connect/Disconnect Button
              if (!dashboardState.demoMode && !bluetoothService.isAuthenticated)
                FloatingActionButton(
                  heroTag: "bluetooth",
                  mini: true,
                  onPressed: bluetoothService.isConnecting ? null : () => bluetoothService.connectToDevice(),
                  backgroundColor: const Color(0xFF1A1A1A),
                  child: bluetoothService.isConnecting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
                          ),
                        )
                      : const Icon(
                          Icons.bluetooth,
                          color: Color(0xFF00D9FF),
                          size: 20,
                        ),
                ),

              if (!dashboardState.demoMode && bluetoothService.isAuthenticated)
                FloatingActionButton(
                  heroTag: "disconnect",
                  mini: true,
                  onPressed: () => bluetoothService.disconnect(),
                  backgroundColor: const Color(0xFFFF5722),
                  child: const Icon(
                    Icons.bluetooth_disabled,
                    color: Colors.white,
                    size: 20,
                  ),
                ),

              const SizedBox(height: 8),

              // Demo Mode Toggle
              FloatingActionButton.extended(
                heroTag: "demo",
                onPressed: () => dashboardState.toggleDemoMode(),
                backgroundColor: dashboardState.demoMode ? const Color(0xFFFF5722) : const Color(0xFF1A1A1A),
                icon: Icon(
                  dashboardState.demoMode ? Icons.stop : Icons.play_arrow,
                  color: dashboardState.demoMode ? Colors.white : const Color(0xFF00FF41),
                ),
                label: Text(
                  dashboardState.demoMode ? 'STOP DEMO' : 'START DEMO',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'FiraCode',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
