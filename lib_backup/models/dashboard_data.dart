class DashboardData {
  // Vehicle speed and engine data
  final double speed;
  final double rpm;

  // Trip information
  final double tripDistance;
  final double fuelUsage;
  final double avgTemperature;
  final double avgSpeed;

  // Gauge readings
  final double coolantTemp;
  final double fuelLevel;

  // Warning indicators
  final bool oilWarning;

  // Battery information
  final double batteryVoltage;

  // Light controls
  final bool drlOn;
  final bool lowBeamOn;
  final bool highBeamOn;
  final bool leftTurnSignal;
  final bool rightTurnSignal;
  final bool hazardLights;

  const DashboardData({
    this.speed = 0.0,
    this.rpm = 0.0,
    this.tripDistance = 0.0,
    this.fuelUsage = 0.0,
    this.avgTemperature = 0.0,
    this.avgSpeed = 0.0,
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

  DashboardData copyWith({
    double? speed,
    double? rpm,
    double? tripDistance,
    double? fuelUsage,
    double? avgTemperature,
    double? avgSpeed,
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
    return DashboardData(
      speed: speed ?? this.speed,
      rpm: rpm ?? this.rpm,
      tripDistance: tripDistance ?? this.tripDistance,
      fuelUsage: fuelUsage ?? this.fuelUsage,
      avgTemperature: avgTemperature ?? this.avgTemperature,
      avgSpeed: avgSpeed ?? this.avgSpeed,
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
    return 'DashboardData('
        'speed: $speed, '
        'rpm: $rpm, '
        'tripDistance: $tripDistance, '
        'fuelUsage: $fuelUsage, '
        'avgTemperature: $avgTemperature, '
        'avgSpeed: $avgSpeed, '
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
