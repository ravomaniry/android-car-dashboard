import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/dashboard_state.dart';
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
    _blinkController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _blinkAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut));
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
                            batteryVoltage: data.batteryVoltage,
                            blinkAnimation: _blinkAnimation,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Coolant Temperature
                        Expanded(child: CoolantGauge(temperature: data.coolantTemp)),
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
                          child: SpeedometerWidget(speed: data.speed, rpm: data.rpm),
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
                        Expanded(child: FuelGauge(fuelLevel: data.fuelLevel)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
