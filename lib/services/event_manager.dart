import 'dart:async';
import 'package:flutter/foundation.dart';

class EventManager extends ChangeNotifier {
  static final EventManager _instance = EventManager._internal();
  factory EventManager() => _instance;
  EventManager._internal();

  // Event streams for GPS and Bluetooth
  final StreamController<GpsEvent> _gpsEventController = StreamController<GpsEvent>.broadcast();
  final StreamController<BluetoothEvent> _bluetoothEventController = StreamController<BluetoothEvent>.broadcast();

  // Latest events lists (keep last 10)
  final List<GpsEvent> _latestGpsEvents = [];
  final List<BluetoothEvent> _latestBluetoothEvents = [];

  // Getters
  Stream<GpsEvent> get gpsEventStream => _gpsEventController.stream;
  Stream<BluetoothEvent> get bluetoothEventStream => _bluetoothEventController.stream;
  List<GpsEvent> get latestGpsEvents => List.unmodifiable(_latestGpsEvents);
  List<BluetoothEvent> get latestBluetoothEvents => List.unmodifiable(_latestBluetoothEvents);

  // Add GPS event
  void addGpsEvent(String message, String level) {
    final event = GpsEvent(message: message, level: level, timestamp: DateTime.now());

    _latestGpsEvents.insert(0, event);
    if (_latestGpsEvents.length > 10) {
      _latestGpsEvents.removeLast();
    }

    _gpsEventController.add(event);
    notifyListeners();
    debugPrint('GPS Event [$level]: $message');
  }

  // Add Bluetooth event
  void addBluetoothEvent(String message, String level) {
    final event = BluetoothEvent(message: message, level: level, timestamp: DateTime.now());

    _latestBluetoothEvents.insert(0, event);
    if (_latestBluetoothEvents.length > 10) {
      _latestBluetoothEvents.removeLast();
    }

    _bluetoothEventController.add(event);
    notifyListeners();
    debugPrint('Bluetooth Event [$level]: $message');
  }

  @override
  void dispose() {
    _gpsEventController.close();
    _bluetoothEventController.close();
    super.dispose();
  }
}

class GpsEvent {
  final String message;
  final String level;
  final DateTime timestamp;

  GpsEvent({required this.message, required this.level, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {'message': message, 'level': level, 'timestamp': timestamp};
  }
}

class BluetoothEvent {
  final String message;
  final String level;
  final DateTime timestamp;

  BluetoothEvent({required this.message, required this.level, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {'message': message, 'level': level, 'timestamp': timestamp};
  }
}
