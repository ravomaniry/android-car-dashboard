import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/dashboard_state.dart';
import '../themes/dashboard_theme.dart';
import 'themed/analog_light_indicator.dart';

class BatteryIndicator extends StatelessWidget {
  final double batteryVoltage;
  final Animation<double> blinkAnimation;
  final bool isCompact;

  const BatteryIndicator({
    super.key,
    required this.batteryVoltage,
    required this.blinkAnimation,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardState>(
      builder: (context, dashboardState, child) {
        final theme = dashboardState.currentTheme;

        if (isCompact) {
          return _buildCompactBatteryItem(theme);
        }

        return _buildBatteryItem(theme);
      },
    );
  }

  Widget _buildCompactBatteryItem(DashboardTheme theme) {
    bool isLowVoltage = batteryVoltage > 0 && batteryVoltage < 12.0;
    Color voltageColor = isLowVoltage ? Colors.red : const Color(0xFF00FF41);

    if (theme.gaugeStyle == GaugeStyle.analog) {
      return Center(
        child: AnalogLightIndicator(
          isActive: isLowVoltage,
          activeColor: theme.dangerColor,
          inactiveColor: theme.successColor,
          size: theme.iconSize * 1.5,
          icon: Icons.battery_alert,
        ),
      );
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: theme.gaugeStyle == GaugeStyle.digital
          ? null // Transparent background for Modern theme
          : BoxDecoration(
              color: const Color(0xFF1A1A1A),
              border: Border.all(color: isLowVoltage ? Colors.red : const Color(0xFF333333), width: 1),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: voltageColor.withValues(alpha: 0.1), blurRadius: 8)],
            ),
      child: Center(
        child: AnimatedBuilder(
          animation: blinkAnimation,
          builder: (context, child) {
            Color iconColor = isLowVoltage
                ? Color.lerp(Colors.red.withValues(alpha: 0.3), Colors.red, blinkAnimation.value)!
                : voltageColor;

            return Icon(isLowVoltage ? Icons.battery_alert : Icons.battery_full, color: iconColor, size: 24);
          },
        ),
      ),
    );
  }

  Widget _buildBatteryItem(DashboardTheme theme) {
    // Determine battery status based on voltage
    bool isLowVoltage = batteryVoltage > 0 && batteryVoltage < 12.0;
    Color voltageColor = isLowVoltage ? Colors.red : const Color(0xFF00FF41);
    String voltageText = batteryVoltage > 0 ? '${batteryVoltage.toStringAsFixed(1)}V' : '0.0V';

    if (theme.gaugeStyle == GaugeStyle.analog) {
      return Center(
        child: AnalogLightIndicator(
          isActive: isLowVoltage,
          activeColor: theme.dangerColor,
          inactiveColor: theme.successColor,
          size: theme.iconSize * 1.5,
          icon: Icons.battery_alert,
        ),
      );
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: theme.gaugeStyle == GaugeStyle.digital
          ? null // Transparent background for Modern theme
          : BoxDecoration(
              color: const Color(0xFF1A1A1A),
              border: Border.all(color: isLowVoltage ? Colors.red : const Color(0xFF333333), width: 1),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: voltageColor.withValues(alpha: 0.1), blurRadius: 8)],
            ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: blinkAnimation,
            builder: (context, child) {
              Color iconColor = isLowVoltage
                  ? Color.lerp(Colors.red.withValues(alpha: 0.3), Colors.red, blinkAnimation.value)!
                  : voltageColor;

              return Icon(isLowVoltage ? Icons.battery_alert : Icons.battery_full, color: iconColor, size: 20);
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'BATTERY',
                  style: GoogleFonts.firaCode(
                    color: const Color(0xFF888888),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  voltageText,
                  style: GoogleFonts.firaCode(color: voltageColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
