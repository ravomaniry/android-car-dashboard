import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/dashboard_state.dart';
import '../themes/dashboard_theme.dart';
import 'themed/analog_light_indicator.dart';

class OilWarningIndicator extends StatelessWidget {
  final bool oilWarning;
  final Animation<double> blinkAnimation;
  final bool isCompact;

  const OilWarningIndicator({
    super.key,
    required this.oilWarning,
    required this.blinkAnimation,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardState>(
      builder: (context, dashboardState, child) {
        final theme = dashboardState.currentTheme;

        if (isCompact) {
          return _buildCompactWarningItem('OIL', oilWarning, Icons.opacity, theme);
        }

        return _buildWarningItem('OIL', oilWarning, Icons.opacity, 'PRESSURE OK', 'LOW PRESSURE', theme);
      },
    );
  }

  Widget _buildCompactWarningItem(String label, bool isWarning, IconData icon, DashboardTheme theme) {
    if (theme.gaugeStyle == GaugeStyle.analog) {
      return Center(
        child: AnalogLightIndicator(
          isActive: isWarning,
          activeColor: theme.dangerColor,
          inactiveColor: theme.inactiveColor,
          size: theme.iconSize * 1.5,
          icon: icon,
        ),
      );
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: theme.gaugeStyle == GaugeStyle.digital
          ? null // Transparent background for Modern theme
          : BoxDecoration(
              color: theme.containerColor,
              borderRadius: BorderRadius.circular(theme.borderRadius),
              border: Border.all(color: isWarning ? theme.dangerColor : theme.borderColor, width: theme.borderWidth),
            ),
      child: Center(
        child: AnimatedBuilder(
          animation: blinkAnimation,
          builder: (context, child) {
            return Icon(
              icon,
              color: isWarning
                  ? Color.lerp(Colors.red.withValues(alpha: 0.3), Colors.red, blinkAnimation.value)
                  : const Color(0xFF00FF41),
              size: 24,
            );
          },
        ),
      ),
    );
  }

  Widget _buildWarningItem(
    String label,
    bool isWarning,
    IconData icon,
    String okMessage,
    String warningMessage,
    DashboardTheme theme,
  ) {
    if (theme.gaugeStyle == GaugeStyle.analog) {
      return Center(
        child: AnalogLightIndicator(
          isActive: isWarning,
          activeColor: theme.dangerColor,
          inactiveColor: theme.inactiveColor,
          size: theme.iconSize * 1.5,
          icon: icon,
        ),
      );
    }
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: theme.gaugeStyle == GaugeStyle.digital
          ? null // Transparent background for Modern theme
          : BoxDecoration(
              color: theme.containerColor,
              borderRadius: BorderRadius.circular(theme.borderRadius),
              border: Border.all(color: isWarning ? theme.dangerColor : theme.borderColor, width: theme.borderWidth),
            ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: blinkAnimation,
            builder: (context, child) {
              return Icon(
                icon,
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
                  label,
                  style: GoogleFonts.firaCode(
                    color: isWarning ? Colors.red : const Color(0xFF00FF41),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isWarning ? warningMessage : okMessage,
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
    );
  }
}
