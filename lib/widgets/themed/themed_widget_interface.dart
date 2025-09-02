import 'package:flutter/material.dart';
import '../../themes/dashboard_theme.dart';

/// Base interface for all themed widgets
abstract class ThemedWidget extends StatelessWidget {
  const ThemedWidget({super.key});

  /// Build the widget with the given theme
  Widget buildForTheme(BuildContext context, DashboardTheme theme);

  @override
  Widget build(BuildContext context) {
    // This will be implemented by concrete widgets using Consumer<DashboardState>
    throw UnimplementedError('Themed widgets must implement their own build method');
  }
}

/// Mixin for widgets that need different implementations per theme
mixin MultiThemedWidget {
  /// Build widget for Linux/htop theme
  Widget buildLinux(BuildContext context, DashboardTheme theme);

  /// Build widget for Classic/analog theme
  Widget buildClassic(BuildContext context, DashboardTheme theme);

  /// Build widget for Modern/digital theme
  Widget buildModern(BuildContext context, DashboardTheme theme);

  /// Build widget for Tesla/minimalist theme
  Widget buildTesla(BuildContext context, DashboardTheme theme);

  /// Build the appropriate widget based on theme
  Widget buildForTheme(BuildContext context, DashboardTheme theme) {
    switch (theme.gaugeStyle) {
      case GaugeStyle.htop:
        return buildLinux(context, theme);
      case GaugeStyle.analog:
        return buildClassic(context, theme);
      case GaugeStyle.digital:
        return buildModern(context, theme);
      case GaugeStyle.elegant:
        return buildTesla(context, theme);
    }
  }
}
