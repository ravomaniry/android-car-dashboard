import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/dashboard_state.dart';
import '../themes/dashboard_theme.dart';
import 'themed/analog_light_indicator.dart';

class LightingIndicators extends StatelessWidget {
  final bool drlOn;
  final bool lowBeamOn;
  final bool highBeamOn;
  final Animation<double> blinkAnimation;
  final bool isCompact;

  const LightingIndicators({
    super.key,
    required this.drlOn,
    required this.lowBeamOn,
    required this.highBeamOn,
    required this.blinkAnimation,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardState>(
      builder: (context, dashboardState, child) {
        final theme = dashboardState.currentTheme;

        if (isCompact) {
          return Row(
            children: [
              Expanded(child: _buildCompactLightIndicator('DRL', Icons.wb_sunny, drlOn, theme)),
              const SizedBox(width: 4),
              Expanded(child: _buildCompactLightIndicator('LOW', Icons.lightbulb_outline, lowBeamOn, theme)),
              const SizedBox(width: 4),
              Expanded(child: _buildCompactLightIndicator('HIGH', Icons.highlight, highBeamOn, theme)),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LIGHTING SYSTEMS',
              style: GoogleFonts.firaCode(color: const Color(0xFF888888), fontSize: 10, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildLightIndicator('DRL', 'Daytime Running Lights', Icons.wb_sunny, drlOn, false, theme),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildLightIndicator(
                    'LOW',
                    'Low Beam Headlights',
                    Icons.lightbulb_outline,
                    lowBeamOn,
                    false,
                    theme,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildLightIndicator(
                    'HIGH',
                    'High Beam Headlights',
                    Icons.highlight,
                    highBeamOn,
                    false,
                    theme,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLightIndicator(
    String label,
    String description,
    IconData icon,
    bool isOn,
    bool shouldBlink,
    DashboardTheme theme,
  ) {
    if (theme.gaugeStyle == GaugeStyle.analog) {
      return Center(
        child: AnalogLightIndicator(
          isActive: isOn,
          activeColor: theme.primaryAccentColor,
          inactiveColor: theme.inactiveColor,
          size: theme.iconSize * 1.2,
          icon: icon,
        ),
      );
    }
    return Container(
      height: 60,
      padding: const EdgeInsets.all(6),
      decoration: theme.gaugeStyle == GaugeStyle.digital
          ? null // Transparent background for Modern theme
          : BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: isOn ? const Color(0xFF00FF41) : const Color(0xFF333333), width: 1),
            ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: blinkAnimation,
            builder: (context, child) {
              final color = isOn
                  ? (shouldBlink
                        ? Color.lerp(
                            const Color(0xFF00FF41).withValues(alpha: 0.3),
                            const Color(0xFF00FF41),
                            blinkAnimation.value,
                          )
                        : const Color(0xFF00FF41))
                  : const Color(0xFF333333);

              return Icon(icon, color: color, size: 14);
            },
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.firaCode(
                color: isOn ? const Color(0xFF00FF41) : const Color(0xFF666666),
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              isOn ? 'ON' : 'OFF',
              style: GoogleFonts.firaCode(color: isOn ? const Color(0xFF888888) : const Color(0xFF444444), fontSize: 6),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLightIndicator(String label, IconData icon, bool isOn, DashboardTheme theme) {
    if (theme.gaugeStyle == GaugeStyle.analog) {
      return Center(
        child: AnalogLightIndicator(
          isActive: isOn,
          activeColor: theme.primaryAccentColor,
          inactiveColor: theme.inactiveColor,
          size: theme.iconSize * 1.2,
          icon: icon,
        ),
      );
    }
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: theme.gaugeStyle == GaugeStyle.digital
          ? null // Transparent background for Modern theme
          : BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: isOn ? const Color(0xFF00FF41) : const Color(0xFF333333), width: 1),
            ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isOn ? const Color(0xFF00FF41) : const Color(0xFF333333), size: 12),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.firaCode(
                color: isOn ? const Color(0xFF00FF41) : const Color(0xFF666666),
                fontSize: 6,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              isOn ? 'ON' : 'OFF',
              style: GoogleFonts.firaCode(color: isOn ? const Color(0xFF888888) : const Color(0xFF444444), fontSize: 4),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
