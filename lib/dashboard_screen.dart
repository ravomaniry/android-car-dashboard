import 'package:flutter/material.dart';
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

  // Mock data - in real app this would come from car sensors
  double speed = 65.0;
  double rpm = 2500.0;
  double tripDistance = 245.8;
  double fuelUsage = 8.5;
  double avgTemperature = 22.0;
  double avgSpeed = 58.2;
  double coolantTemp = 85.0;
  double fuelLevel = 65.0;
  bool oilWarning = false;
  bool drlOn = true;
  bool lowBeamOn = false;
  bool highBeamOn = false;
  bool leftTurnSignal = false;
  bool rightTurnSignal = false;
  bool hazardLights = false;

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
        child: Padding(
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
                        oilWarning: oilWarning,
                        blinkAnimation: _blinkAnimation,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Coolant Temperature
                    Expanded(
                      child: CoolantGauge(temperature: coolantTemp),
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
                        speed: speed,
                        rpm: rpm,
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
                              value: '${tripDistance.toStringAsFixed(1)} km',
                              icon: Icons.straighten,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TripDetailItem(
                              label: 'FUEL USE',
                              value: '${fuelUsage.toStringAsFixed(1)} L/100km',
                              icon: Icons.local_gas_station,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TripDetailItem(
                              label: 'AVG TEMP',
                              value: '${avgTemperature.toStringAsFixed(0)}°C',
                              icon: Icons.thermostat,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TripDetailItem(
                              label: 'AVG SPEED',
                              value: '${avgSpeed.toStringAsFixed(1)} km/h',
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
                        drlOn: drlOn,
                        lowBeamOn: lowBeamOn,
                        highBeamOn: highBeamOn,
                        leftTurnSignal: leftTurnSignal,
                        rightTurnSignal: rightTurnSignal,
                        hazardLights: hazardLights,
                        blinkAnimation: _blinkAnimation,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Fuel Level
                    Expanded(
                      child: FuelGauge(fuelLevel: fuelLevel),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Debug controls for demonstration
          FloatingActionButton(
            mini: true,
            backgroundColor: const Color(0xFF00FF41),
            onPressed: () {
              setState(() {
                oilWarning = !oilWarning;
              });
            },
            child: const Icon(Icons.warning, color: Colors.black),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            mini: true,
            backgroundColor: const Color(0xFF00FF41),
            onPressed: () {
              setState(() {
                leftTurnSignal = !leftTurnSignal;
              });
            },
            child: const Icon(Icons.turn_left, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
