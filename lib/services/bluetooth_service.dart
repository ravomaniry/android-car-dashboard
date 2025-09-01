import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/dashboard_data.dart';
import 'dashboard_state.dart';
import 'event_manager.dart';

class BluetoothService extends ChangeNotifier {
  static const String targetDeviceName = 'RAVO_CAR_DASH';

  BluetoothConnection? _connection;
  bool _isConnecting = false;
  bool _isAuthenticated = false;
  String _status = 'Disconnected';

  final DashboardState _dashboardState;

  // Retry logic variables
  int _retryAttempts = 0;
  static const int _maxRetryAttempts = 5;
  Timer? _retryTimer;

  // Getters
  bool get isConnected => _connection?.isConnected ?? false;
  bool get isConnecting => _isConnecting;
  bool get isAuthenticated => _isAuthenticated;
  String get status => _status;

  BluetoothService(this._dashboardState) {
    // Auto-connect on service initialization
    _autoConnect();
  }

  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final permissions = [
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.location,
      ];

      final statuses = await permissions.request();
      return statuses.values.every(
        (status) => status == PermissionStatus.granted || status == PermissionStatus.limited,
      );
    }
    return true; // iOS doesn't need explicit permission for basic Bluetooth
  }

  Future<void> connectToDevice() async {
    if (_isConnecting) return;

    _setStatus('Requesting permissions...');

    if (!await requestPermissions()) {
      _setStatus('Permissions denied');
      return;
    }

    EventManager().addBluetoothEvent('Requesting Bluetooth permissions...', 'INFO');

    _isConnecting = true;
    _setStatus('Scanning for devices...');
    EventManager().addBluetoothEvent('Scanning for Bluetooth devices...', 'INFO');

    try {
      // Get list of bonded devices
      List<BluetoothDevice> bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
      EventManager().addBluetoothEvent('Found ${bondedDevices.length} bonded devices', 'INFO');

      BluetoothDevice? targetDevice;
      for (BluetoothDevice device in bondedDevices) {
        if (device.name == targetDeviceName) {
          targetDevice = device;
          break;
        }
      }

      if (targetDevice == null) {
        _setStatus('Device not found. Please pair $targetDeviceName first.');
        EventManager().addBluetoothEvent('Target device $targetDeviceName not found', 'ERROR');
        _isConnecting = false;
        return;
      }

      _setStatus('Connecting to ${targetDevice.name}...');
      EventManager().addBluetoothEvent('Connecting to ${targetDevice.name}...', 'INFO');

      // Connect to the device
      BluetoothConnection connection = await BluetoothConnection.toAddress(targetDevice.address);
      _connection = connection;

      _setStatus('Connected. Ready for data...');
      EventManager().addBluetoothEvent('Bluetooth connection established', 'STATUS');

      // Skip authentication since it's disabled on the device
      _isAuthenticated = true;
      _dashboardState.setConnectionStatus('Connected', connected: true);
      _setStatus('Ready');
      EventManager().addBluetoothEvent('Bluetooth authentication successful', 'STATUS');

      // Start listening for data immediately
      _listenForData();
      EventManager().addBluetoothEvent('Started listening for data...', 'INFO');
    } catch (e) {
      _setStatus('Connection failed: ${e.toString()}');
    } finally {
      _isConnecting = false;
    }
  }

  void _listenForData() {
    _connection?.input?.listen(
      (Uint8List data) {
        String received = String.fromCharCodes(data).trim();
        _parseIncomingData(received);
      },
      onError: (error) {
        debugPrint('Bluetooth data error: $error');
        _setStatus('Data reception error');
      },
      onDone: () {
        _setStatus('Connection closed');
        _disconnect();
      },
    );
  }

  void _parseIncomingData(String data) {
    // Parse JSON data from ESP32
    // Expected format: {"coolantTemp":82.0,"fuelLevel":65.0,"oilWarning":false,...}

    // Skip empty or whitespace-only data
    if (data.trim().isEmpty) {
      return;
    }

    try {
      final Map<String, dynamic> json = jsonDecode(data.trim());

      final esp32SensorData = Esp32SensorData(
        coolantTemp: (json['coolantTemp'] ?? 0.0).toDouble(),
        fuelLevel: (json['fuelLevel'] ?? 0.0).toDouble(),
        oilWarning: json['oilWarning'] ?? false,
        batteryVoltage: (json['batteryVoltage'] ?? 0.0).toDouble(),
        drlOn: json['drlOn'] ?? false,
        lowBeamOn: json['lowBeamOn'] ?? false,
        highBeamOn: json['highBeamOn'] ?? false,
        leftTurnSignal: json['leftTurnSignal'] ?? false,
        rightTurnSignal: json['rightTurnSignal'] ?? false,
        hazardLights: json['hazardLights'] ?? false,
      );

      debugPrint(
        'Successfully parsed sensor data: coolant=${esp32SensorData.coolantTemp}°C, fuel=${esp32SensorData.fuelLevel}%, battery=${esp32SensorData.batteryVoltage}V',
      );
      _dashboardState.updateEsp32SensorData(esp32SensorData);

      // Add Bluetooth data events to the event stream
      _addBluetoothEvent('Received coolant temp: ${esp32SensorData.coolantTemp.toStringAsFixed(1)}°C', 'DATA');
      _addBluetoothEvent('Received fuel level: ${esp32SensorData.fuelLevel.toStringAsFixed(1)}%', 'DATA');
      _addBluetoothEvent('Received battery voltage: ${esp32SensorData.batteryVoltage.toStringAsFixed(1)}V', 'DATA');
    } catch (e) {
      // Only log parsing errors for non-empty data that looks like JSON
      if (data.trim().isNotEmpty && (data.contains('{') || data.contains('}'))) {
        debugPrint('Failed to parse incoming data: "$data", Error: $e');
      }
    }
  }

  Future<void> _disconnect() async {
    try {
      await _connection?.close();
    } catch (e) {
      debugPrint('Error closing connection: $e');
    }

    _connection = null;
    _isAuthenticated = false;
    _dashboardState.setConnectionStatus('Disconnected', connected: false);
    _setStatus('Disconnected');
  }

  void _setStatus(String status) {
    _status = status;
    notifyListeners();
  }

  // Method to add Bluetooth events to the event stream
  void _addBluetoothEvent(String message, String level) {
    EventManager().addBluetoothEvent(message, level);
  }

  Future<void> disconnect() async {
    await _disconnect();
  }

  Future<void> _autoConnect() async {
    // Wait a bit for the app to initialize
    await Future.delayed(const Duration(seconds: 2));

    // Start retry logic with exponential backoff
    await _connectWithRetry();
  }

  Future<void> _connectWithRetry() async {
    // Only auto-connect if not already connected/connecting
    if (_isConnecting || isConnected) return;

    debugPrint('Bluetooth connection attempt ${_retryAttempts + 1}/${_maxRetryAttempts + 1}');
    await connectToDevice();

    // If connection failed and we haven't exceeded max attempts
    if (!isConnected && !_isAuthenticated && _retryAttempts < _maxRetryAttempts) {
      _retryAttempts++;

      // Calculate exponential backoff delay: 2^attempt seconds (2, 4, 8, 16, 32)
      final delaySeconds = (2 << (_retryAttempts - 1)).clamp(2, 60); // Cap at 60 seconds

      debugPrint(
        'Bluetooth connection failed, retrying in $delaySeconds seconds... (attempt $_retryAttempts/$_maxRetryAttempts)',
      );
      _setStatus('Retrying in ${delaySeconds}s...');

      _retryTimer?.cancel();
      _retryTimer = Timer(Duration(seconds: delaySeconds), () {
        if (!_isConnecting && !isConnected) {
          _connectWithRetry();
        }
      });
    } else if (!isConnected && !_isAuthenticated) {
      // Max retries exceeded
      debugPrint('Bluetooth connection failed after $_maxRetryAttempts attempts. Giving up.');
      _setStatus('Connection failed - max retries exceeded');
      _retryAttempts = 0; // Reset for future manual attempts
    } else if (isConnected && _isAuthenticated) {
      // Success! Reset retry counter
      _retryAttempts = 0;
      _retryTimer?.cancel();
    }
  }

  // Public method to manually retry connection (resets retry counter)
  Future<void> retryConnection() async {
    _retryTimer?.cancel();
    _retryAttempts = 0;
    await _connectWithRetry();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _disconnect();
    super.dispose();
  }
}
