import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/dashboard_state.dart';
import '../themes/dashboard_theme.dart';

import 'themed/analog_light_indicator.dart';

class TripDetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const TripDetailItem({super.key, required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardState>(
      builder: (context, dashboardState, child) {
        final theme = dashboardState.currentTheme;

        return Container(
          height: 100,
          padding: EdgeInsets.all(theme.containerPadding.top * 0.5), // Scale padding to fit
          decoration: theme.gaugeStyle == GaugeStyle.analog
              ? BoxDecoration(color: theme.backgroundColor, borderRadius: BorderRadius.circular(theme.borderRadius))
              : theme.gaugeStyle == GaugeStyle.digital
              ? theme.getMetallicContainerDecoration()
              : theme.gaugeStyle == GaugeStyle.elegant
              ? null // No background for Tesla theme
              : theme.getContainerDecoration().copyWith(
                  border: Border.all(color: theme.secondaryAccentColor, width: theme.borderWidth),
                  boxShadow: [
                    BoxShadow(
                      color: theme.secondaryAccentColor.withValues(alpha: 0.1),
                      blurRadius: theme.shadowBlurRadius,
                      offset: theme.shadowOffset,
                    ),
                  ],
                ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Fix overflow
            children: [
              if (theme.gaugeStyle == GaugeStyle.analog)
                AnalogLightIndicator(
                  isActive: true,
                  activeColor: theme.secondaryAccentColor,
                  inactiveColor: theme.inactiveColor,
                  size: theme.iconSize * 1.5,
                  icon: icon,
                )
              else
                Icon(icon, color: theme.secondaryAccentColor, size: theme.iconSize),
              SizedBox(height: theme.borderRadius * 0.25), // Responsive spacing
              Flexible(
                // Allow text to shrink if needed
                child: Text(
                  label,
                  style: theme.getBodyTextStyle(fontSize: 8, color: theme.textSecondaryColor),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: theme.borderRadius * 0.2),
              Flexible(
                // Allow text to shrink if needed
                child: Text(
                  value,
                  style: theme
                      .getBodyTextStyle(fontSize: 10, color: theme.secondaryAccentColor)
                      .copyWith(fontWeight: theme.headerFontWeight),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
