import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/dashboard_data.dart';

class DashboardState extends ChangeNotifier {
  DashboardData _data = const DashboardData();
  Esp32SensorData _esp32Data = const Esp32SensorData();
  bool _demoMode = false;
  bool _bluetoothConnected = false;
  String _connectionStatus = 'Disconnected';
  bool _isSmallScreen = false;

  // Fuel usage calculation variables
  double? _previousFuelLevel;
  double _totalFuelUsed = 0.0;
  DateTime? _lastFuelUpdate;

  // Temperature averaging variables
  List<double> _temperatureHistory = [];
  static const int _tempHistorySize = 50; // Keep last 50 temperature readings

  // Demo mode timers
  Timer? _demoTimer;
  Timer? _booleanToggleTimer;
  int _demoStep = 0;

  // Getters
  DashboardData get data => _data;
  bool get demoMode => _demoMode;
  bool get bluetoothConnected => _bluetoothConnected;
  String get connectionStatus => _connectionStatus;
  bool get isSmallScreen => _isSmallScreen;

  // Update ESP32 sensor data (called by BluetoothService)
  void updateEsp32SensorData(Esp32SensorData newSensorData) {
    if (!_demoMode) {
      _esp32Data = newSensorData;
      _calculateFuelUsage();
      _updateTemperatureAverage();
      _combineDashboardData();
      notifyListeners();
    }
  }

  // Update GPS calculated data (called by GpsService)
  void updateGpsData({required double speed, required double tripDistance, required double avgSpeed}) {
    if (!_demoMode) {
      _data = _data.copyWith(speed: speed, tripDistance: tripDistance, avgSpeed: avgSpeed);
      _combineDashboardData();
      notifyListeners();
    }
  }

  // Combine ESP32 sensor data with GPS calculated data
  void _combineDashboardData() {
    _data = _data.copyWith(
      sensorData: _esp32Data,
      fuelUsage: _totalFuelUsed,
      avgTemperature: _calculateAverageTemperature(),
    );
  }

  // Calculate fuel usage based on fuel level changes
  void _calculateFuelUsage() {
    final now = DateTime.now();

    if (_previousFuelLevel != null && _lastFuelUpdate != null) {
      final fuelDifference = _previousFuelLevel! - _esp32Data.fuelLevel;

      // Only count as fuel usage if:
      // 1. Fuel level decreased (not increased due to refueling)
      // 2. Decrease is reasonable (less than 20% in one reading)
      // 3. Some time has passed since last update
      if (fuelDifference > 0 && fuelDifference < 20.0 && now.difference(_lastFuelUpdate!).inSeconds > 5) {
        _totalFuelUsed += fuelDifference;
      }
    }

    _previousFuelLevel = _esp32Data.fuelLevel;
    _lastFuelUpdate = now;
  }

  // Update temperature history for averaging
  void _updateTemperatureAverage() {
    _temperatureHistory.add(_esp32Data.coolantTemp);
    if (_temperatureHistory.length > _tempHistorySize) {
      _temperatureHistory.removeAt(0);
    }
  }

  // Calculate average temperature
  double _calculateAverageTemperature() {
    if (_temperatureHistory.isEmpty) return 0.0;

    final sum = _temperatureHistory.reduce((a, b) => a + b);
    return sum / _temperatureHistory.length;
  }

  // Legacy method for backward compatibility
  void updateData(DashboardData newData) {
    if (!_demoMode) {
      _data = newData;
      notifyListeners();
    }
  }

  // Update partial data (legacy method for backward compatibility)
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
      // Update GPS calculated data
      _data = _data.copyWith(
        speed: speed,
        rpm: rpm,
        tripDistance: tripDistance,
        fuelUsage: fuelUsage,
        avgTemperature: avgTemperature,
        avgSpeed: avgSpeed,
      );

      // Update ESP32 sensor data if provided
      if (coolantTemp != null ||
          fuelLevel != null ||
          oilWarning != null ||
          drlOn != null ||
          lowBeamOn != null ||
          highBeamOn != null ||
          leftTurnSignal != null ||
          rightTurnSignal != null ||
          hazardLights != null) {
        _esp32Data = _esp32Data.copyWith(
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
        _data = _data.copyWith(sensorData: _esp32Data);
      }

      notifyListeners();
    }
  }

  // Connection status management
  void setConnectionStatus(String status, {bool connected = false}) {
    _connectionStatus = status;
    _bluetoothConnected = connected;
    notifyListeners();
  }

  // Small screen state management
  Set<String> _sectionsRequestingSmallScreen = {};

  void requestSmallScreenMode(String sectionName) {
    _sectionsRequestingSmallScreen.add(sectionName);
    if (!_isSmallScreen) {
      _isSmallScreen = true;
      notifyListeners();
    }
  }

  void requestBigScreenMode(String sectionName) {
    _sectionsRequestingSmallScreen.remove(sectionName);

    // Only exit small screen mode if NO sections are requesting it
    if (_sectionsRequestingSmallScreen.isEmpty && _isSmallScreen) {
      _isSmallScreen = false;
      notifyListeners();
    }
  }

  void setSmallScreenMode(bool isSmall) {
    _isSmallScreen = isSmall;
    if (!isSmall) {
      // Clear all section requests when manually setting to big screen mode
      _sectionsRequestingSmallScreen.clear();
    }
    notifyListeners();
  }

  // Debug method to see which sections are requesting small screen mode
  Set<String> get sectionsRequestingSmallScreen => _sectionsRequestingSmallScreen;

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

    // Update ESP32 sensor data
    _esp32Data = _esp32Data.copyWith(
      // Coolant temp: 60 to 120°C (critical range)
      coolantTemp: 60 + sineWave * 60,
      // Fuel level: 0 to 100%
      fuelLevel: cosWave * 100,
      // Battery voltage: 11.5 to 14.4V (typical car battery range)
      batteryVoltage: 11.5 + sineWave * 2.9,
    );

    // Update GPS calculated data
    _data = _data.copyWith(
      // Speed: 0 to 200 km/h
      speed: sineWave * 200,
      // RPM: 800 to 7000 (not used anymore but kept for compatibility)
      rpm: 800 + sineWave * 6200,
      // Trip distance: 0 to 999.9 km
      tripDistance: progress * 999.9,
      // Fuel usage: 3.0 to 15.0 L/100km
      fuelUsage: 3.0 + cosWave * 12.0,
      // Avg temperature: -20 to 45°C
      avgTemperature: -20 + sineWave * 65,
      // Avg speed: 0 to 120 km/h
      avgSpeed: cosWave * 120,
      // Update sensor data
      sensorData: _esp32Data,
    );
  }

  void _toggleBooleanValues() {
    // Randomly toggle boolean values in ESP32 sensor data
    final random = math.Random();

    _esp32Data = _esp32Data.copyWith(
      oilWarning: random.nextBool() ? !_esp32Data.oilWarning : _esp32Data.oilWarning,
      drlOn: random.nextBool() ? !_esp32Data.drlOn : _esp32Data.drlOn,
      lowBeamOn: random.nextBool() ? !_esp32Data.lowBeamOn : _esp32Data.lowBeamOn,
      highBeamOn: random.nextBool() ? !_esp32Data.highBeamOn : _esp32Data.highBeamOn,
      leftTurnSignal: random.nextBool() ? !_esp32Data.leftTurnSignal : _esp32Data.leftTurnSignal,
      rightTurnSignal: random.nextBool() ? !_esp32Data.rightTurnSignal : _esp32Data.rightTurnSignal,
      hazardLights: random.nextBool() ? !_esp32Data.hazardLights : _esp32Data.hazardLights,
    );

    // Update the main data with new sensor data
    _data = _data.copyWith(sensorData: _esp32Data);
  }

  // Reset fuel usage (called when starting a new trip)
  void resetFuelUsage() {
    _totalFuelUsed = 0.0;
    _previousFuelLevel = _esp32Data.fuelLevel;
    _lastFuelUpdate = DateTime.now();
    _combineDashboardData();
    notifyListeners();
  }

  // Reset temperature average (called when starting a new trip)
  void resetTemperatureAverage() {
    _temperatureHistory.clear();
    _combineDashboardData();
    notifyListeners();
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    _booleanToggleTimer?.cancel();
    super.dispose();
  }
}
