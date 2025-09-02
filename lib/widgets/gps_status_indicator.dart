import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/gps_service.dart';
import '../services/event_manager.dart';
import '../services/dashboard_state.dart';
import '../themes/dashboard_theme.dart';
import 'service_status_dialog.dart';
import 'themed/analog_light_indicator.dart';

class GpsStatusIndicator extends StatelessWidget {
  final Animation<double> blinkAnimation;
  final bool isCompact;

  const GpsStatusIndicator({super.key, required this.blinkAnimation, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    return Consumer2<GpsService, DashboardState>(
      builder: (context, gpsService, dashboardState, child) {
        final isTracking = gpsService.isTracking;
        final hasPermission = gpsService.hasLocationPermission;
        final theme = dashboardState.currentTheme;

        bool isWarning = !hasPermission || !isTracking;

        if (isCompact) {
          return _buildCompactGpsWarning(context, isWarning, gpsService, theme);
        }

        return _buildGpsWarningItem(context, isWarning, gpsService, theme);
      },
    );
  }

  Widget _buildCompactGpsWarning(BuildContext context, bool isWarning, GpsService gpsService, DashboardTheme theme) {
    if (theme.gaugeStyle == GaugeStyle.analog) {
      return GestureDetector(
        onTap: () {
          _showGpsDialog(context, gpsService);
        },
        child: Center(
          child: AnalogLightIndicator(
            isActive: isWarning,
            activeColor: theme.dangerColor,
            inactiveColor: theme.successColor,
            size: theme.iconSize * 1.5,
            icon: Icons.gps_fixed,
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        _showGpsDialog(context, gpsService);
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
                Icons.gps_fixed,
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

  Widget _buildGpsWarningItem(BuildContext context, bool isWarning, GpsService gpsService, DashboardTheme theme) {
    if (theme.gaugeStyle == GaugeStyle.analog) {
      return GestureDetector(
        onTap: () {
          _showGpsDialog(context, gpsService);
        },
        child: Center(
          child: AnalogLightIndicator(
            isActive: isWarning,
            activeColor: theme.dangerColor,
            inactiveColor: theme.successColor,
            size: theme.iconSize * 1.5,
            icon: Icons.gps_fixed,
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        _showGpsDialog(context, gpsService);
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
                  Icons.gps_fixed,
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
                    'GPS',
                    style: GoogleFonts.firaCode(
                      color: isWarning ? Colors.red : const Color(0xFF00FF41),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isWarning ? 'NOT TRACKING' : 'TRACKING',
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

  void _showGpsDialog(BuildContext context, GpsService gpsService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer2<GpsService, EventManager>(
          builder: (context, gpsService, eventManager, child) {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(gpsService.status, style: GoogleFonts.firaCode(color: Colors.white, fontSize: 12)),
                      const SizedBox(height: 12),

                      // GPS Info: Speed | Last Update | Accuracy
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF333333), width: 1),
                        ),
                        child: Column(
                          children: [
                            // Speed
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Speed:',
                                  style: GoogleFonts.firaCode(color: const Color(0xFF888888), fontSize: 10),
                                ),
                                Text(
                                  '${gpsService.currentSpeed.toStringAsFixed(1)} km/h',
                                  style: GoogleFonts.firaCode(
                                    color: const Color(0xFF00FF41),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Last Update
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Last Update:',
                                  style: GoogleFonts.firaCode(color: const Color(0xFF888888), fontSize: 10),
                                ),
                                Text(
                                  gpsService.lastUpdateTime != null
                                      ? _getRelativeTime(gpsService.lastUpdateTime!)
                                      : 'Never',
                                  style: GoogleFonts.firaCode(
                                    color: const Color(0xFF00D9FF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Accuracy
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Accuracy:',
                                  style: GoogleFonts.firaCode(color: const Color(0xFF888888), fontSize: 10),
                                ),
                                Text(
                                  gpsService.currentAccuracy != null
                                      ? '${gpsService.currentAccuracy!.toStringAsFixed(1)}m'
                                      : 'N/A',
                                  style: GoogleFonts.firaCode(
                                    color: _getAccuracyColor(gpsService.currentAccuracy),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            final actions = [
              ElevatedButton.icon(
                onPressed: () async {
                  await gpsService.getCurrentLocation();
                  // Location test completed silently - no popup messages
                },
                icon: const Icon(Icons.location_on, color: Colors.white, size: 16),
                label: Text('Test Location', style: GoogleFonts.firaCode(color: Colors.white, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D9FF),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close', style: GoogleFonts.firaCode(color: const Color(0xFF00D9FF))),
              ),
            ];

            return ServiceStatusDialog(
              title: 'GPS Service',
              icon: Icons.gps_fixed,
              leftContent: leftContent,
              events: eventManager.latestGpsEvents,
              actions: actions,
            );
          },
        );
      },
    );
  }

  String _getRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} sec ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
  }

  Color _getAccuracyColor(double? accuracy) {
    if (accuracy == null) return const Color(0xFF666666);

    if (accuracy <= 10) {
      return const Color(0xFF00FF41); // Green for high accuracy
    } else if (accuracy <= 50) {
      return const Color(0xFFFF9800); // Orange for medium accuracy
    } else {
      return const Color(0xFFFF5722); // Red for low accuracy
    }
  }
}
