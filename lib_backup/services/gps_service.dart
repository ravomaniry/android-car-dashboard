import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/trip_data.dart';
import '../models/dashboard_data.dart';
import 'dashboard_state.dart';

class GpsService extends ChangeNotifier {
  final DashboardState _dashboardState;

  StreamSubscription<Position>? _positionStream;
  TripData? _currentTrip;
  Position? _lastPosition;
  DateTime? _lastUpdateTime;

  // GPS tracking state
  bool _isTracking = false;
  bool _hasLocationPermission = false;
  String _status = 'GPS Disabled';

  // Trip calculation variables
  double _totalDistance = 0.0;
  double _currentSpeed = 0.0;
  double _maxSpeed = 0.0;
  final List<double> _recentSpeeds = [];
  static const int _speedHistorySize = 10; // Keep last 10 speed readings for averaging

  // Trip average calculation (excluding very slow speeds)
  double _tripAverageDistance = 0.0; // Distance covered at meaningful speeds
  Duration _tripAverageTime = Duration.zero; // Time spent at meaningful speeds
  DateTime? _lastMeaningfulSpeedTime;
  static const double _minSpeedForAverage = 10.0; // Minimum 10 km/h for trip average

  // File storage
  File? _tripDataFile;

  // Getters
  bool get isTracking => _isTracking;
  bool get hasLocationPermission => _hasLocationPermission;
  String get status => _status;
  TripData? get currentTrip => _currentTrip;
  double get currentSpeed => _currentSpeed;

  GpsService(this._dashboardState) {
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _initializeFileStorage();
    await _requestLocationPermissions();
    await _loadCurrentTrip();
  }

  Future<void> _initializeFileStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _tripDataFile = File('${directory.path}/trip_data.json');
      debugPrint('Trip data file: ${_tripDataFile!.path}');
    } catch (e) {
      debugPrint('Error initializing file storage: $e');
    }
  }

  Future<bool> _requestLocationPermissions() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setStatus('Location services disabled');
        return false;
      }

      // Request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setStatus('Location permissions denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setStatus('Location permissions permanently denied');
        return false;
      }

      // Request background location permission
      if (defaultTargetPlatform == TargetPlatform.android) {
        final backgroundPermission = await Permission.locationAlways.request();
        if (backgroundPermission != PermissionStatus.granted) {
          debugPrint('Background location permission not granted');
        }
      }

      _hasLocationPermission = true;
      _setStatus('GPS Ready');
      return true;
    } catch (e) {
      _setStatus('Permission error: $e');
      return false;
    }
  }

  Future<void> startTracking() async {
    if (_isTracking) return;

    if (!_hasLocationPermission) {
      bool permissionGranted = await _requestLocationPermissions();
      if (!permissionGranted) return;
    }

    try {
      _setStatus('Starting GPS...');

      // Start new trip if none exists
      if (_currentTrip == null || !_currentTrip!.isActive) {
        await _startNewTrip();
      }

      // Configure location settings for high accuracy
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // Update every 1 meter
        timeLimit: Duration(seconds: 5), // Timeout after 5 seconds
      );

      _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        _onLocationUpdate,
        onError: (error) {
          debugPrint('GPS error: $error');
          _setStatus('GPS Error: $error');
        },
      );

      _isTracking = true;
      _setStatus('GPS Tracking Active');
      notifyListeners();
    } catch (e) {
      _setStatus('Failed to start GPS: $e');
      debugPrint('Error starting GPS tracking: $e');
    }
  }

  Future<void> stopTracking() async {
    if (!_isTracking) return;

    await _positionStream?.cancel();
    _positionStream = null;
    _isTracking = false;

    // End current trip
    if (_currentTrip != null && _currentTrip!.isActive) {
      await _endCurrentTrip();
    }

    _setStatus('GPS Stopped');
    notifyListeners();
  }

  void _onLocationUpdate(Position position) {
    final now = DateTime.now();

    // Calculate speed (m/s to km/h)
    _currentSpeed = (position.speed * 3.6).clamp(0.0, 300.0); // Cap at 300 km/h

    // Update speed history for averaging
    _recentSpeeds.add(_currentSpeed);
    if (_recentSpeeds.length > _speedHistorySize) {
      _recentSpeeds.removeAt(0);
    }

    // Calculate distance if we have a previous position
    if (_lastPosition != null && _lastUpdateTime != null) {
      double distance =
          Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            position.latitude,
            position.longitude,
          ) /
          1000.0; // Convert to kilometers

      // Only add distance if we're moving (speed > 1 km/h) and distance is reasonable
      if (_currentSpeed > 1.0 && distance < 0.1) {
        _totalDistance += distance;

        // Track distance and time for trip average (only at meaningful speeds)
        if (_currentSpeed >= _minSpeedForAverage) {
          _tripAverageDistance += distance;

          // Calculate time spent at meaningful speed
          if (_lastMeaningfulSpeedTime != null) {
            final timeDiff = now.difference(_lastMeaningfulSpeedTime!);
            _tripAverageTime += timeDiff;
          }
          _lastMeaningfulSpeedTime = now;
        }
      }
    } else if (_currentSpeed >= _minSpeedForAverage) {
      // First meaningful speed reading
      _lastMeaningfulSpeedTime = now;
    }

    // Update max speed
    if (_currentSpeed > _maxSpeed) {
      _maxSpeed = _currentSpeed;
    }

    // Create speed point
    final speedPoint = SpeedPoint(
      timestamp: now,
      speed: _currentSpeed,
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
    );

    // Update current trip
    if (_currentTrip != null) {
      _updateCurrentTrip(speedPoint);
    }

    // Update dashboard with current data
    _updateDashboard();

    _lastPosition = position;
    _lastUpdateTime = now;

    _setStatus('GPS: ${_currentSpeed.toStringAsFixed(1)} km/h');
  }

  Future<void> _startNewTrip() async {
    _currentTrip = TripData(startTime: DateTime.now(), isActive: true);

    // Reset trip variables
    _totalDistance = 0.0;
    _maxSpeed = 0.0;
    _recentSpeeds.clear();
    _lastPosition = null;
    _lastUpdateTime = null;

    // Reset trip average calculation
    _tripAverageDistance = 0.0;
    _tripAverageTime = Duration.zero;
    _lastMeaningfulSpeedTime = null;

    await _saveCurrentTrip();
    debugPrint('New trip started: ${_currentTrip!.startTime}');
  }

  void _updateCurrentTrip(SpeedPoint speedPoint) {
    if (_currentTrip == null) return;

    final updatedSpeedPoints = List<SpeedPoint>.from(_currentTrip!.speedPoints)..add(speedPoint);

    // Calculate true trip average speed (excluding very slow speeds)
    double tripAvgSpeed = 0.0;
    if (_tripAverageTime.inSeconds > 0 && _tripAverageDistance > 0) {
      tripAvgSpeed = _tripAverageDistance / (_tripAverageTime.inSeconds / 3600.0); // km/h
    }

    // Calculate total time
    final totalTime = DateTime.now().difference(_currentTrip!.startTime);

    _currentTrip = _currentTrip!.copyWith(
      totalDistance: _totalDistance,
      maxSpeed: _maxSpeed,
      averageSpeed: tripAvgSpeed, // Now shows true trip average
      totalTime: totalTime,
      speedPoints: updatedSpeedPoints,
    );

    // Save every 10 updates to avoid excessive file I/O
    if (updatedSpeedPoints.length % 10 == 0) {
      _saveCurrentTrip();
    }
  }

  Future<void> _endCurrentTrip() async {
    if (_currentTrip == null || !_currentTrip!.isActive) return;

    _currentTrip = _currentTrip!.copyWith(endTime: DateTime.now(), isActive: false);

    await _saveCurrentTrip();
    debugPrint('Trip ended: ${_currentTrip!.endTime}');
  }

  void _updateDashboard() {
    // Calculate true trip average speed (distance/time at meaningful speeds)
    double tripAvgSpeed = 0.0;
    if (_tripAverageTime.inSeconds > 0 && _tripAverageDistance > 0) {
      tripAvgSpeed = _tripAverageDistance / (_tripAverageTime.inSeconds / 3600.0); // km/h
    }

    // Update dashboard state with GPS data
    _dashboardState.updatePartialData(
      speed: _currentSpeed,
      tripDistance: _totalDistance,
      avgSpeed: tripAvgSpeed, // Now shows true trip average
    );
  }

  Future<void> _saveCurrentTrip() async {
    if (_tripDataFile == null || _currentTrip == null) return;

    try {
      final jsonString = _currentTrip!.toJsonString();
      await _tripDataFile!.writeAsString(jsonString);
    } catch (e) {
      debugPrint('Error saving trip data: $e');
    }
  }

  Future<void> _loadCurrentTrip() async {
    if (_tripDataFile == null) return;

    try {
      if (await _tripDataFile!.exists()) {
        final jsonString = await _tripDataFile!.readAsString();
        _currentTrip = TripData.fromJsonString(jsonString);

        // If trip is still active, resume tracking variables
        if (_currentTrip!.isActive) {
          _totalDistance = _currentTrip!.totalDistance;
          _maxSpeed = _currentTrip!.maxSpeed;
          debugPrint('Resumed active trip: ${_currentTrip!.startTime}');
        }
      }
    } catch (e) {
      debugPrint('Error loading trip data: $e');
      _currentTrip = null;
    }
  }

  Future<void> resetTrip() async {
    await stopTracking();
    _currentTrip = null;
    _totalDistance = 0.0;
    _maxSpeed = 0.0;
    _recentSpeeds.clear();

    // Reset trip average calculation
    _tripAverageDistance = 0.0;
    _tripAverageTime = Duration.zero;
    _lastMeaningfulSpeedTime = null;

    // Clear the file
    if (_tripDataFile != null && await _tripDataFile!.exists()) {
      await _tripDataFile!.delete();
    }

    _updateDashboard();
    notifyListeners();
  }

  void _setStatus(String status) {
    _status = status;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}
