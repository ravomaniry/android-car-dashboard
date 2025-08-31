// ESP32 sensor data - received from ESP32 via Bluetooth
class Esp32SensorData {
  final double coolantTemp;
  final double fuelLevel;
  final bool oilWarning;
  final double batteryVoltage;
  final bool drlOn;
  final bool lowBeamOn;
  final bool highBeamOn;
  final bool leftTurnSignal;
  final bool rightTurnSignal;
  final bool hazardLights;

  const Esp32SensorData({
    this.coolantTemp = 0.0,
    this.fuelLevel = 0.0,
    this.oilWarning = false,
    this.batteryVoltage = 0.0,
    this.drlOn = false,
    this.lowBeamOn = false,
    this.highBeamOn = false,
    this.leftTurnSignal = false,
    this.rightTurnSignal = false,
    this.hazardLights = false,
  });

  Esp32SensorData copyWith({
    double? coolantTemp,
    double? fuelLevel,
    bool? oilWarning,
    double? batteryVoltage,
    bool? drlOn,
    bool? lowBeamOn,
    bool? highBeamOn,
    bool? leftTurnSignal,
    bool? rightTurnSignal,
    bool? hazardLights,
  }) {
    return Esp32SensorData(
      coolantTemp: coolantTemp ?? this.coolantTemp,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      oilWarning: oilWarning ?? this.oilWarning,
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      drlOn: drlOn ?? this.drlOn,
      lowBeamOn: lowBeamOn ?? this.lowBeamOn,
      highBeamOn: highBeamOn ?? this.highBeamOn,
      leftTurnSignal: leftTurnSignal ?? this.leftTurnSignal,
      rightTurnSignal: rightTurnSignal ?? this.rightTurnSignal,
      hazardLights: hazardLights ?? this.hazardLights,
    );
  }

  @override
  String toString() {
    return 'Esp32SensorData('
        'coolantTemp: $coolantTemp, '
        'fuelLevel: $fuelLevel, '
        'oilWarning: $oilWarning, '
        'batteryVoltage: $batteryVoltage, '
        'drlOn: $drlOn, '
        'lowBeamOn: $lowBeamOn, '
        'highBeamOn: $highBeamOn, '
        'leftTurnSignal: $leftTurnSignal, '
        'rightTurnSignal: $rightTurnSignal, '
        'hazardLights: $hazardLights'
        ')';
  }
}

// Complete dashboard data - combines ESP32 sensor data with GPS-calculated data
class DashboardData {
  // GPS-calculated data
  final double speed;
  final double rpm; // Can be removed if not needed
  final double tripDistance;
  final double fuelUsage;
  final double avgTemperature;
  final double avgSpeed;

  // ESP32 sensor data
  final Esp32SensorData sensorData;

  const DashboardData({
    this.speed = 0.0,
    this.rpm = 0.0,
    this.tripDistance = 0.0,
    this.fuelUsage = 0.0,
    this.avgTemperature = 0.0,
    this.avgSpeed = 0.0,
    this.sensorData = const Esp32SensorData(),
  });

  DashboardData copyWith({
    double? speed,
    double? rpm,
    double? tripDistance,
    double? fuelUsage,
    double? avgTemperature,
    double? avgSpeed,
    Esp32SensorData? sensorData,
  }) {
    return DashboardData(
      speed: speed ?? this.speed,
      rpm: rpm ?? this.rpm,
      tripDistance: tripDistance ?? this.tripDistance,
      fuelUsage: fuelUsage ?? this.fuelUsage,
      avgTemperature: avgTemperature ?? this.avgTemperature,
      avgSpeed: avgSpeed ?? this.avgSpeed,
      sensorData: sensorData ?? this.sensorData,
    );
  }

  @override
  String toString() {
    return 'DashboardData('
        'speed: $speed, '
        'rpm: $rpm, '
        'tripDistance: $tripDistance, '
        'fuelUsage: $fuelUsage, '
        'avgTemperature: $avgTemperature, '
        'avgSpeed: $avgSpeed, '
        'sensorData: $sensorData'
        ')';
  }

  // Helper getters for backward compatibility
  double get coolantTemp => sensorData.coolantTemp;
  double get fuelLevel => sensorData.fuelLevel;
  bool get oilWarning => sensorData.oilWarning;
  double get batteryVoltage => sensorData.batteryVoltage;
  bool get drlOn => sensorData.drlOn;
  bool get lowBeamOn => sensorData.lowBeamOn;
  bool get highBeamOn => sensorData.highBeamOn;
  bool get leftTurnSignal => sensorData.leftTurnSignal;
  bool get rightTurnSignal => sensorData.rightTurnSignal;
  bool get hazardLights => sensorData.hazardLights;
}
