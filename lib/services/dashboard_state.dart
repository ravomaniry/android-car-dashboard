import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/dashboard_data.dart';

class DashboardState extends ChangeNotifier {
  DashboardData _data = const DashboardData();
  bool _demoMode = false;
  bool _bluetoothConnected = false;
  String _connectionStatus = 'Disconnected';

  // Demo mode timers
  Timer? _demoTimer;
  Timer? _booleanToggleTimer;
  int _demoStep = 0;

  // Getters
  DashboardData get data => _data;
  bool get demoMode => _demoMode;
  bool get bluetoothConnected => _bluetoothConnected;
  String get connectionStatus => _connectionStatus;

  // Update dashboard data
  void updateData(DashboardData newData) {
    if (!_demoMode) {
      // Only update if not in demo mode
      _data = newData;
      notifyListeners();
    }
  }

  // Update partial data
  void updatePartialData({
    double? speed,
    double? rpm,
    double? tripDistance,
    double? fuelUsage,
    double? avgTemperature,
    double? avgSpeed,
    double? coolantTemp,
    double? fuelLevel,
    bool? oilWarning,
    bool? drlOn,
    bool? lowBeamOn,
    bool? highBeamOn,
    bool? leftTurnSignal,
    bool? rightTurnSignal,
    bool? hazardLights,
  }) {
    if (!_demoMode) {
      // Only update if not in demo mode
      _data = _data.copyWith(
        speed: speed,
        rpm: rpm,
        tripDistance: tripDistance,
        fuelUsage: fuelUsage,
        avgTemperature: avgTemperature,
        avgSpeed: avgSpeed,
        coolantTemp: coolantTemp,
        fuelLevel: fuelLevel,
        oilWarning: oilWarning,
        drlOn: drlOn,
        lowBeamOn: lowBeamOn,
        highBeamOn: highBeamOn,
        leftTurnSignal: leftTurnSignal,
        rightTurnSignal: rightTurnSignal,
        hazardLights: hazardLights,
      );
      notifyListeners();
    }
  }

  // Connection status management
  void setConnectionStatus(String status, {bool connected = false}) {
    _connectionStatus = status;
    _bluetoothConnected = connected;
    notifyListeners();
  }

  // Demo mode management
  void toggleDemoMode() {
    _demoMode = !_demoMode;

    if (_demoMode) {
      _startDemoMode();
    } else {
      _stopDemoMode();
    }

    notifyListeners();
  }

  void _startDemoMode() {
    _demoStep = 0;

    // Start smooth value transitions (100ms intervals for smooth animation)
    _demoTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _updateDemoValues();
      notifyListeners();
    });

    // Start boolean toggles (every 2 seconds)
    _booleanToggleTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _toggleBooleanValues();
      notifyListeners();
    });

    setConnectionStatus('Demo Mode Active', connected: false);
  }

  void _stopDemoMode() {
    _demoTimer?.cancel();
    _booleanToggleTimer?.cancel();

    // Reset to default values
    _data = const DashboardData();
    setConnectionStatus('Disconnected', connected: false);
  }

  void _updateDemoValues() {
    _demoStep++;
    final progress = (_demoStep % 200) / 200.0; // 20 second cycle
    final sineWave = (math.sin(progress * 2 * math.pi) + 1) / 2; // 0 to 1
    final cosWave = (math.cos(progress * 2 * math.pi) + 1) / 2; // 0 to 1

    _data = _data.copyWith(
      // Speed: 0 to 200 km/h
      speed: sineWave * 200,
      // RPM: 800 to 7000
      rpm: 800 + sineWave * 6200,
      // Trip distance: 0 to 999.9 km
      tripDistance: progress * 999.9,
      // Fuel usage: 3.0 to 15.0 L/100km
      fuelUsage: 3.0 + cosWave * 12.0,
      // Avg temperature: -20 to 45°C
      avgTemperature: -20 + sineWave * 65,
      // Avg speed: 0 to 120 km/h
      avgSpeed: cosWave * 120,
      // Coolant temp: 60 to 120°C (critical range)
      coolantTemp: 60 + sineWave * 60,
      // Fuel level: 0 to 100%
      fuelLevel: cosWave * 100,
      // Battery voltage: 11.5 to 14.4V (typical car battery range)
      batteryVoltage: 11.5 + sineWave * 2.9,
    );
  }

  void _toggleBooleanValues() {
    // Randomly toggle boolean values
    final random = math.Random();

    _data = _data.copyWith(
      oilWarning: random.nextBool() ? !_data.oilWarning : _data.oilWarning,
      drlOn: random.nextBool() ? !_data.drlOn : _data.drlOn,
      lowBeamOn: random.nextBool() ? !_data.lowBeamOn : _data.lowBeamOn,
      highBeamOn: random.nextBool() ? !_data.highBeamOn : _data.highBeamOn,
      leftTurnSignal: random.nextBool() ? !_data.leftTurnSignal : _data.leftTurnSignal,
      rightTurnSignal: random.nextBool() ? !_data.rightTurnSignal : _data.rightTurnSignal,
      hazardLights: random.nextBool() ? !_data.hazardLights : _data.hazardLights,
    );
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    _booleanToggleTimer?.cancel();
    super.dispose();
  }
}
