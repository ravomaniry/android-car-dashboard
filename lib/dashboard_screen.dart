import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
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

  // Demo mode state
  bool _demoMode = false;
  Timer? _demoTimer;
  Timer? _booleanToggleTimer;
  int _demoStep = 0;

  // Default values
  static const double _defaultSpeed = 0.0;
  static const double _defaultRpm = 0.0;
  static const double _defaultTripDistance = 0.0;
  static const double _defaultFuelUsage = 0.0;
  static const double _defaultAvgTemperature = 0.0;
  static const double _defaultAvgSpeed = 0.0;
  static const double _defaultCoolantTemp = 0.0;
  static const double _defaultFuelLevel = 0.0;
  static const bool _defaultOilWarning = false;
  static const bool _defaultDrlOn = false;
  static const bool _defaultLowBeamOn = false;
  static const bool _defaultHighBeamOn = false;
  static const bool _defaultLeftTurnSignal = false;
  static const bool _defaultRightTurnSignal = false;
  static const bool _defaultHazardLights = false;

  // Current values - Mock data - in real app this would come from car sensors
  double speed = _defaultSpeed;
  double rpm = _defaultRpm;
  double tripDistance = _defaultTripDistance;
  double fuelUsage = _defaultFuelUsage;
  double avgTemperature = _defaultAvgTemperature;
  double avgSpeed = _defaultAvgSpeed;
  double coolantTemp = _defaultCoolantTemp;
  double fuelLevel = _defaultFuelLevel;
  bool oilWarning = _defaultOilWarning;
  bool drlOn = _defaultDrlOn;
  bool lowBeamOn = _defaultLowBeamOn;
  bool highBeamOn = _defaultHighBeamOn;
  bool leftTurnSignal = _defaultLeftTurnSignal;
  bool rightTurnSignal = _defaultRightTurnSignal;
  bool hazardLights = _defaultHazardLights;

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
    _demoTimer?.cancel();
    _booleanToggleTimer?.cancel();
    super.dispose();
  }

  void _toggleDemoMode() {
    setState(() {
      _demoMode = !_demoMode;
    });

    if (_demoMode) {
      _startDemoMode();
    } else {
      _stopDemoMode();
    }
  }

  void _startDemoMode() {
    _demoStep = 0;

    // Start smooth value transitions (100ms intervals for smooth animation)
    _demoTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _updateDemoValues();
      });
    });

    // Start boolean toggles (every 2 seconds)
    _booleanToggleTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _toggleBooleanValues();
      });
    });
  }

  void _stopDemoMode() {
    _demoTimer?.cancel();
    _booleanToggleTimer?.cancel();

    // Reset to default values
    setState(() {
      speed = _defaultSpeed;
      rpm = _defaultRpm;
      tripDistance = _defaultTripDistance;
      fuelUsage = _defaultFuelUsage;
      avgTemperature = _defaultAvgTemperature;
      avgSpeed = _defaultAvgSpeed;
      coolantTemp = _defaultCoolantTemp;
      fuelLevel = _defaultFuelLevel;
      oilWarning = _defaultOilWarning;
      drlOn = _defaultDrlOn;
      lowBeamOn = _defaultLowBeamOn;
      highBeamOn = _defaultHighBeamOn;
      leftTurnSignal = _defaultLeftTurnSignal;
      rightTurnSignal = _defaultRightTurnSignal;
      hazardLights = _defaultHazardLights;
    });
  }

  void _updateDemoValues() {
    _demoStep++;
    final progress = (_demoStep % 200) / 200.0; // 20 second cycle
    final sineWave = (math.sin(progress * 2 * math.pi) + 1) / 2; // 0 to 1
    final cosWave = (math.cos(progress * 2 * math.pi) + 1) / 2; // 0 to 1

    // Speed: 0 to 200 km/h
    speed = sineWave * 200;

    // RPM: 800 to 7000
    rpm = 800 + sineWave * 6200;

    // Trip distance: 0 to 999.9 km
    tripDistance = progress * 999.9;

    // Fuel usage: 3.0 to 15.0 L/100km
    fuelUsage = 3.0 + cosWave * 12.0;

    // Avg temperature: -20 to 45°C
    avgTemperature = -20 + sineWave * 65;

    // Avg speed: 0 to 120 km/h
    avgSpeed = cosWave * 120;

    // Coolant temp: 60 to 120°C (critical range)
    coolantTemp = 60 + sineWave * 60;

    // Fuel level: 0 to 100%
    fuelLevel = cosWave * 100;
  }

  void _toggleBooleanValues() {
    // Randomly toggle boolean values
    final random = math.Random();

    if (random.nextBool()) oilWarning = !oilWarning;
    if (random.nextBool()) drlOn = !drlOn;
    if (random.nextBool()) lowBeamOn = !lowBeamOn;
    if (random.nextBool()) highBeamOn = !highBeamOn;
    if (random.nextBool()) leftTurnSignal = !leftTurnSignal;
    if (random.nextBool()) rightTurnSignal = !rightTurnSignal;
    if (random.nextBool()) hazardLights = !hazardLights;
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleDemoMode,
        backgroundColor: _demoMode ? const Color(0xFFFF5722) : const Color(0xFF1A1A1A),
        icon: Icon(
          _demoMode ? Icons.stop : Icons.play_arrow,
          color: _demoMode ? Colors.white : const Color(0xFF00FF41),
        ),
        label: Text(
          _demoMode ? 'STOP DEMO' : 'START DEMO',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'FiraCode',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
