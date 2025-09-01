import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/gps_service.dart';
import '../services/bluetooth_service.dart';

class ServiceDialogs {
  static void showGpsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<GpsService>(
          builder: (context, gpsService, child) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: Row(
                children: [
                  Icon(Icons.gps_fixed, color: const Color(0xFF00D9FF)),
                  const SizedBox(width: 8),
                  Text(
                    'GPS Service',
                    style: GoogleFonts.firaCode(
                      color: const Color(0xFF00D9FF),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 500,
                height: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F0F),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF00D9FF), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status:',
                            style: GoogleFonts.firaCode(
                              color: const Color(0xFF00D9FF),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                gpsService.isTracking ? Icons.gps_fixed : Icons.gps_not_fixed,
                                color: gpsService.isTracking ? const Color(0xFF00FF41) : const Color(0xFFFF5722),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  gpsService.status,
                                  style: GoogleFonts.firaCode(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                gpsService.hasLocationPermission ? Icons.check_circle : Icons.cancel,
                                color: gpsService.hasLocationPermission ? const Color(0xFF00FF41) : const Color(0xFFFF5722),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Location Permission: ${gpsService.hasLocationPermission ? "Granted" : "Denied"}',
                                style: GoogleFonts.firaCode(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Test button section
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final position = await gpsService.getCurrentLocation();
                              if (position != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Location obtained: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
                                      style: GoogleFonts.firaCode(),
                                    ),
                                    backgroundColor: const Color(0xFF00FF41),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to get location',
                                      style: GoogleFonts.firaCode(),
                                    ),
                                    backgroundColor: const Color(0xFFFF5722),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.location_on, color: Colors.white),
                            label: Text(
                              'Test Location',
                              style: GoogleFonts.firaCode(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00D9FF),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (gpsService.isTracking) {
                                gpsService.stopTracking();
                              } else {
                                gpsService.startTracking();
                              }
                            },
                            icon: Icon(
                              gpsService.isTracking ? Icons.stop : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            label: Text(
                              gpsService.isTracking ? 'Stop GPS' : 'Start GPS',
                              style: GoogleFonts.firaCode(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: gpsService.isTracking ? const Color(0xFFFF5722) : const Color(0xFF00FF41),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Logs section
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F0F0F),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF666666), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Service Logs:',
                                  style: GoogleFonts.firaCode(
                                    color: const Color(0xFF00D9FF),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    // Refresh logs or clear them
                                  },
                                  icon: const Icon(Icons.refresh, color: Color(0xFF00D9FF), size: 16),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF000000),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                                                             _buildLogEntry('GPS Service initialized', 'INFO'),
                                       _buildLogEntry('Location permission: ${gpsService.hasLocationPermission ? "Granted" : "Denied"}', 'STATUS'),
                                       _buildLogEntry('Tracking status: ${gpsService.isTracking ? "Active" : "Inactive"}', 'STATUS'),
                                       _buildLogEntry('Current status: ${gpsService.status}', 'STATUS'),
                                       _buildLogEntry('Current speed: ${gpsService.currentSpeed.toStringAsFixed(1)} km/h', 'STATUS'),
                                       if (gpsService.currentTrip != null) ...[
                                         _buildLogEntry('Trip started: ${gpsService.currentTrip!.startTime.toString().substring(0, 19)}', 'TRIP'),
                                         _buildLogEntry('Distance: ${gpsService.currentTrip!.totalDistance.toStringAsFixed(2)} km', 'TRIP'),
                                         _buildLogEntry('Max speed: ${gpsService.currentTrip!.maxSpeed.toStringAsFixed(1)} km/h', 'TRIP'),
                                         _buildLogEntry('Avg speed: ${gpsService.currentTrip!.averageSpeed.toStringAsFixed(1)} km/h', 'TRIP'),
                                       ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Close',
                    style: GoogleFonts.firaCode(color: const Color(0xFF00D9FF)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static void showBluetoothDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<BluetoothService>(
          builder: (context, bluetoothService, child) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: Row(
                children: [
                  Icon(Icons.bluetooth, color: const Color(0xFF00D9FF)),
                  const SizedBox(width: 8),
                  Text(
                    'Bluetooth Service',
                    style: GoogleFonts.firaCode(
                      color: const Color(0xFF00D9FF),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 500,
                height: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F0F),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF00D9FF), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status:',
                            style: GoogleFonts.firaCode(
                              color: const Color(0xFF00D9FF),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                bluetoothService.isAuthenticated ? Icons.bluetooth_connected : Icons.bluetooth,
                                color: bluetoothService.isAuthenticated ? const Color(0xFF00FF41) : const Color(0xFFFF5722),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  bluetoothService.status,
                                  style: GoogleFonts.firaCode(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                bluetoothService.isConnecting ? Icons.hourglass_empty : Icons.check_circle,
                                color: bluetoothService.isConnecting ? const Color(0xFFFF9800) : const Color(0xFF00FF41),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Connection: ${bluetoothService.isConnecting ? "Connecting..." : (bluetoothService.isAuthenticated ? "Connected" : "Disconnected")}',
                                style: GoogleFonts.firaCode(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Control buttons section
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: bluetoothService.isConnecting
                                ? null
                                : () {
                                    if (bluetoothService.isAuthenticated) {
                                      bluetoothService.disconnect();
                                    } else {
                                      bluetoothService.connectToDevice();
                                    }
                                  },
                            icon: Icon(
                              bluetoothService.isAuthenticated ? Icons.bluetooth_disabled : Icons.bluetooth,
                              color: Colors.white,
                            ),
                            label: Text(
                              bluetoothService.isAuthenticated ? 'Disconnect' : 'Connect',
                              style: GoogleFonts.firaCode(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: bluetoothService.isAuthenticated ? const Color(0xFFFF5722) : const Color(0xFF00FF41),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: bluetoothService.isConnecting ? null : () => bluetoothService.retryConnection(),
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            label: Text(
                              'Retry',
                              style: GoogleFonts.firaCode(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9800),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Logs section
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F0F0F),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF666666), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Service Logs:',
                                  style: GoogleFonts.firaCode(
                                    color: const Color(0xFF00D9FF),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    // Refresh logs or clear them
                                  },
                                  icon: const Icon(Icons.refresh, color: Color(0xFF00D9FF), size: 16),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF000000),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                                                             _buildLogEntry('Bluetooth Service initialized', 'INFO'),
                                       _buildLogEntry('Target device: RAVO_CAR_DASH', 'CONFIG'),
                                       _buildLogEntry('Connection status: ${bluetoothService.status}', 'STATUS'),
                                       _buildLogEntry('Authenticated: ${bluetoothService.isAuthenticated}', 'STATUS'),
                                       _buildLogEntry('Connecting: ${bluetoothService.isConnecting}', 'STATUS'),
                                       _buildLogEntry('Auto-connect enabled', 'CONFIG'),
                                       _buildLogEntry('Retry attempts: ${bluetoothService.status.contains('retry') ? 'Active' : 'None'}', 'STATUS'),
                                       _buildLogEntry('Connection type: Serial Bluetooth', 'CONFIG'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Close',
                    style: GoogleFonts.firaCode(color: const Color(0xFF00D9FF)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _buildLogEntry(String message, String level) {
    Color levelColor;
    switch (level) {
      case 'INFO':
        levelColor = const Color(0xFF00D9FF);
        break;
      case 'STATUS':
        levelColor = const Color(0xFF00FF41);
        break;
      case 'CONFIG':
        levelColor = const Color(0xFFFF9800);
        break;
      case 'TRIP':
        levelColor = const Color(0xFFE91E63);
        break;
      default:
        levelColor = const Color(0xFF888888);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              level,
              style: GoogleFonts.firaCode(
                color: levelColor,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.firaCode(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
