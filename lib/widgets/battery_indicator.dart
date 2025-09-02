import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    if (isCompact) {
      return _buildCompactBatteryItem();
    }

    return _buildBatteryItem();
  }

  Widget _buildCompactBatteryItem() {
    bool isLowVoltage = batteryVoltage > 0 && batteryVoltage < 12.0;
    Color voltageColor = isLowVoltage ? Colors.red : const Color(0xFF00FF41);

    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
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

  Widget _buildBatteryItem() {
    // Determine battery status based on voltage
    bool isLowVoltage = batteryVoltage > 0 && batteryVoltage < 12.0;
    Color voltageColor = isLowVoltage ? Colors.red : const Color(0xFF00FF41);
    String voltageText = batteryVoltage > 0 ? '${batteryVoltage.toStringAsFixed(1)}V' : '0.0V';

    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
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
