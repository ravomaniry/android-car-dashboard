import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:crypto/crypto.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/dashboard_data.dart';
import 'dashboard_state.dart';

class BluetoothService extends ChangeNotifier {
  static const String targetDeviceName = 'RAVO_CAR_DASH';
  static const String secretSalt = 'super_secret_salt';

  BluetoothConnection? _connection;
  bool _isConnecting = false;
  bool _isAuthenticated = false;
  String _status = 'Disconnected';

  final DashboardState _dashboardState;

  // Getters
  bool get isConnected => _connection?.isConnected ?? false;
  bool get isConnecting => _isConnecting;
  bool get isAuthenticated => _isAuthenticated;
  String get status => _status;

  BluetoothService(this._dashboardState);

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

    _isConnecting = true;
    _setStatus('Scanning for devices...');

    try {
      // Get list of bonded devices
      List<BluetoothDevice> bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();

      BluetoothDevice? targetDevice;
      for (BluetoothDevice device in bondedDevices) {
        if (device.name == targetDeviceName) {
          targetDevice = device;
          break;
        }
      }

      if (targetDevice == null) {
        _setStatus('Device not found. Please pair $targetDeviceName first.');
        _isConnecting = false;
        return;
      }

      _setStatus('Connecting to ${targetDevice.name}...');

      // Connect to the device
      BluetoothConnection connection = await BluetoothConnection.toAddress(targetDevice.address);
      _connection = connection;

      _setStatus('Connected. Authenticating...');

      // Start authentication process
      bool authenticated = await _authenticateWithDevice();

      if (authenticated) {
        _isAuthenticated = true;
        _dashboardState.setConnectionStatus('Connected & Authenticated', connected: true);
        _setStatus('Ready');

        // Start listening for data
        _listenForData();
      } else {
        _setStatus('Authentication failed');
        await _disconnect();
      }
    } catch (e) {
      _setStatus('Connection failed: ${e.toString()}');
    } finally {
      _isConnecting = false;
    }
  }

  Future<bool> _authenticateWithDevice() async {
    if (_connection == null) return false;

    try {
      // Set up a completer to handle the async authentication
      Completer<bool> authCompleter = Completer<bool>();

      // Listen for the challenge from ESP32
      _connection!.input!.listen((Uint8List data) {
        String received = String.fromCharCodes(data).trim();

        if (received.startsWith('CHALLENGE:')) {
          String challenge = received.substring(10); // Remove "CHALLENGE:" prefix

          // Compute the hash response
          String response = _computeAuthResponse(challenge);

          // Send the response
          _connection!.output.add(Uint8List.fromList(utf8.encode('$response\n')));
        } else if (received == 'AUTH OK') {
          if (!authCompleter.isCompleted) {
            authCompleter.complete(true);
          }
        } else if (received == 'AUTH FAIL') {
          if (!authCompleter.isCompleted) {
            authCompleter.complete(false);
          }
        }
      });

      // Wait for authentication result with timeout
      return await authCompleter.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          return false;
        },
      );
    } catch (e) {
      debugPrint('Authentication error: $e');
      return false;
    }
  }

  String _computeAuthResponse(String challenge) {
    // Compute SHA256 hash of challenge + salt (same as ESP32)
    final input = challenge + secretSalt;
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
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
    // Expected format: {"speed":85.5,"rpm":2500,"coolantTemp":82.0,...}
    try {
      final Map<String, dynamic> json = jsonDecode(data);

      final dashboardData = DashboardData(
        speed: (json['speed'] ?? 0.0).toDouble(),
        rpm: (json['rpm'] ?? 0.0).toDouble(),
        tripDistance: (json['tripDistance'] ?? 0.0).toDouble(),
        fuelUsage: (json['fuelUsage'] ?? 0.0).toDouble(),
        avgTemperature: (json['avgTemperature'] ?? 0.0).toDouble(),
        avgSpeed: (json['avgSpeed'] ?? 0.0).toDouble(),
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

      _dashboardState.updateData(dashboardData);
    } catch (e) {
      debugPrint('Failed to parse incoming data: $data, Error: $e');
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

  Future<void> disconnect() async {
    await _disconnect();
  }

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }
}
