import 'dart:convert';

class TripData {
  final DateTime startTime;
  final DateTime? endTime;
  final double totalDistance; // in kilometers
  final double maxSpeed; // in km/h
  final double averageSpeed; // in km/h
  final Duration totalTime;
  final List<SpeedPoint> speedPoints;
  final bool isActive;

  const TripData({
    required this.startTime,
    this.endTime,
    this.totalDistance = 0.0,
    this.maxSpeed = 0.0,
    this.averageSpeed = 0.0,
    this.totalTime = Duration.zero,
    this.speedPoints = const [],
    this.isActive = true,
  });

  TripData copyWith({
    DateTime? startTime,
    DateTime? endTime,
    double? totalDistance,
    double? maxSpeed,
    double? averageSpeed,
    Duration? totalTime,
    List<SpeedPoint>? speedPoints,
    bool? isActive,
  }) {
    return TripData(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDistance: totalDistance ?? this.totalDistance,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      totalTime: totalTime ?? this.totalTime,
      speedPoints: speedPoints ?? this.speedPoints,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'totalDistance': totalDistance,
      'maxSpeed': maxSpeed,
      'averageSpeed': averageSpeed,
      'totalTimeSeconds': totalTime.inSeconds,
      'speedPoints': speedPoints.map((point) => point.toJson()).toList(),
      'isActive': isActive,
    };
  }

  factory TripData.fromJson(Map<String, dynamic> json) {
    return TripData(
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime']),
      endTime: json['endTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['endTime'])
          : null,
      totalDistance: (json['totalDistance'] ?? 0.0).toDouble(),
      maxSpeed: (json['maxSpeed'] ?? 0.0).toDouble(),
      averageSpeed: (json['averageSpeed'] ?? 0.0).toDouble(),
      totalTime: Duration(seconds: json['totalTimeSeconds'] ?? 0),
      speedPoints: (json['speedPoints'] as List<dynamic>?)
              ?.map((point) => SpeedPoint.fromJson(point))
              .toList() ??
          [],
      isActive: json['isActive'] ?? false,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory TripData.fromJsonString(String jsonString) =>
      TripData.fromJson(jsonDecode(jsonString));

  @override
  String toString() {
    return 'TripData(startTime: $startTime, totalDistance: ${totalDistance.toStringAsFixed(2)}km, averageSpeed: ${averageSpeed.toStringAsFixed(1)}km/h)';
  }
}

class SpeedPoint {
  final DateTime timestamp;
  final double speed; // in km/h
  final double latitude;
  final double longitude;
  final double altitude; // in meters

  const SpeedPoint({
    required this.timestamp,
    required this.speed,
    required this.latitude,
    required this.longitude,
    this.altitude = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'speed': speed,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
    };
  }

  factory SpeedPoint.fromJson(Map<String, dynamic> json) {
    return SpeedPoint(
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      speed: (json['speed'] ?? 0.0).toDouble(),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      altitude: (json['altitude'] ?? 0.0).toDouble(),
    );
  }
}
