import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import '../services/event_manager.dart';
import 'service_status_dialog.dart';

class BluetoothStatusIndicator extends StatelessWidget {
  final Animation<double> blinkAnimation;
  final bool isCompact;

  const BluetoothStatusIndicator({super.key, required this.blinkAnimation, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothService>(
      builder: (context, bluetoothService, child) {
        final isConnected = bluetoothService.isConnected;
        final isConnecting = bluetoothService.isConnecting;

        bool isWarning = !isConnected && !isConnecting;

        if (isCompact) {
          return _buildCompactBluetoothWarning(context, isWarning, bluetoothService);
        }

        return _buildBluetoothWarningItem(context, isWarning, bluetoothService);
      },
    );
  }

  Widget _buildCompactBluetoothWarning(BuildContext context, bool isWarning, BluetoothService bluetoothService) {
    return GestureDetector(
      onTap: () {
        _showBluetoothDialog(context, bluetoothService);
      },
      child: Container(
        height: 60,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isWarning ? Colors.red : const Color(0xFF333333), width: 1),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: blinkAnimation,
            builder: (context, child) {
              return Icon(
                Icons.bluetooth,
                color: isWarning
                    ? Color.lerp(Colors.red.withValues(alpha: 0.3), Colors.red, blinkAnimation.value)
                    : const Color(0xFF00FF41),
                size: 24,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBluetoothWarningItem(BuildContext context, bool isWarning, BluetoothService bluetoothService) {
    return GestureDetector(
      onTap: () {
        _showBluetoothDialog(context, bluetoothService);
      },
      child: Container(
        height: 60,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isWarning ? Colors.red : const Color(0xFF333333), width: 1),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: blinkAnimation,
              builder: (context, child) {
                return Icon(
                  Icons.bluetooth,
                  color: isWarning
                      ? Color.lerp(Colors.red.withValues(alpha: 0.3), Colors.red, blinkAnimation.value)
                      : const Color(0xFF00FF41),
                  size: 16,
                );
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'BLUETOOTH',
                    style: GoogleFonts.firaCode(
                      color: isWarning ? Colors.red : const Color(0xFF00FF41),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isWarning ? 'DISCONNECTED' : 'CONNECTED',
                    style: GoogleFonts.firaCode(color: isWarning ? Colors.red : const Color(0xFF888888), fontSize: 8),
                  ),
                ],
              ),
            ),
            if (isWarning)
              AnimatedBuilder(
                animation: blinkAnimation,
                builder: (context, child) {
                  return Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color.lerp(Colors.red.withValues(alpha: 0.3), Colors.red, blinkAnimation.value),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showBluetoothDialog(BuildContext context, BluetoothService bluetoothService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer2<BluetoothService, EventManager>(
          builder: (context, bluetoothService, eventManager, child) {
            final leftContent = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Status:',
                  style: GoogleFonts.firaCode(
                    color: const Color(0xFF00D9FF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.circular(4)),
                  child: Text(bluetoothService.status, style: GoogleFonts.firaCode(color: Colors.white, fontSize: 12)),
                ),
              ],
            );

            final actions = [
              ElevatedButton.icon(
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
                  size: 16,
                ),
                label: Text(
                  bluetoothService.isAuthenticated ? 'Disconnect' : 'Connect',
                  style: GoogleFonts.firaCode(color: Colors.white, fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: bluetoothService.isAuthenticated ? const Color(0xFFFF5722) : const Color(0xFF00FF41),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                ),
              ),
              ElevatedButton.icon(
                onPressed: bluetoothService.isConnecting ? null : () => bluetoothService.retryConnection(),
                icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
                label: Text('Retry', style: GoogleFonts.firaCode(color: Colors.white, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close', style: GoogleFonts.firaCode(color: const Color(0xFF00D9FF))),
              ),
            ];

            return ServiceStatusDialog(
              title: 'Bluetooth Service',
              icon: Icons.bluetooth,
              leftContent: leftContent,
              events: eventManager.latestBluetoothEvents,
              actions: actions,
            );
          },
        );
      },
    );
  }
}
