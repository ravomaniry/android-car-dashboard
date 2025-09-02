import 'package:flutter/material.dart';

enum DashboardThemeType { linux, classic, modern, woman }

enum GaugeStyle {
  htop, // Linux terminal style with ticks
  analog, // Classic car analog gauges
  digital, // Modern car digital displays
  elegant, // Elegant curves and gradients
}

class DashboardTheme {
  final String name;
  final Color backgroundColor;
  final Color containerColor;
  final Color borderColor;
  final Color primaryAccentColor;
  final Color secondaryAccentColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final Color speedometerColor;
  final Color tachometerColor;
  final Color successColor;
  final Color warningColor;
  final Color dangerColor;
  final Color inactiveColor;
  final Color shadowColor;

  // Visual styling properties
  final double borderRadius;
  final double borderWidth;
  final double shadowBlurRadius;
  final Offset shadowOffset;
  final String fontFamily;
  final FontWeight headerFontWeight;
  final FontWeight bodyFontWeight;
  final double iconSize;
  final EdgeInsets containerPadding;
  final GaugeStyle gaugeStyle;
  final bool useGradients;
  final bool showDecorations;
  final double elementSpacing;

  const DashboardTheme({
    required this.name,
    required this.backgroundColor,
    required this.containerColor,
    required this.borderColor,
    required this.primaryAccentColor,
    required this.secondaryAccentColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.speedometerColor,
    required this.tachometerColor,
    required this.successColor,
    required this.warningColor,
    required this.dangerColor,
    required this.inactiveColor,
    required this.shadowColor,
    required this.borderRadius,
    required this.borderWidth,
    required this.shadowBlurRadius,
    required this.shadowOffset,
    required this.fontFamily,
    required this.headerFontWeight,
    required this.bodyFontWeight,
    required this.iconSize,
    required this.containerPadding,
    required this.gaugeStyle,
    required this.useGradients,
    required this.showDecorations,
    required this.elementSpacing,
  });

  // Linux theme - Terminal/htop style with ASCII-like elements
  static const DashboardTheme linux = DashboardTheme(
    name: 'Linux',
    backgroundColor: Color(0xFF0A0A0A),
    containerColor: Color(0xFF1A1A1A),
    borderColor: Color(0xFF00FF41),
    primaryAccentColor: Color(0xFF00FF41),
    secondaryAccentColor: Color(0xFF00D9FF),
    textPrimaryColor: Color(0xFF00D9FF),
    textSecondaryColor: Color(0xFF888888),
    speedometerColor: Color(0xFF00D9FF),
    tachometerColor: Color(0xFF00D9FF),
    successColor: Color(0xFF00FF41),
    warningColor: Color(0xFFFF9800),
    dangerColor: Color(0xFFFF5722),
    inactiveColor: Color(0xFF444444),
    shadowColor: Color(0x4000FF41),
    borderRadius: 4.0,
    borderWidth: 1.0,
    shadowBlurRadius: 4.0,
    shadowOffset: Offset(0, 1),
    fontFamily: 'FiraCode',
    headerFontWeight: FontWeight.bold,
    bodyFontWeight: FontWeight.normal,
    iconSize: 16.0,
    containerPadding: EdgeInsets.all(12.0),
    gaugeStyle: GaugeStyle.htop,
    useGradients: false,
    showDecorations: false,
    elementSpacing: 8.0,
  );

  // Classic car dashboard theme - Blue and black analog gauges
  static const DashboardTheme classic = DashboardTheme(
    name: 'Classic',
    backgroundColor: Color(0xFF000000),
    containerColor: Color(0xFF1A1A1A),
    borderColor: Color(0xFF1E88E5),
    primaryAccentColor: Color(0xFF1E88E5),
    secondaryAccentColor: Color(0xFF42A5F5),
    textPrimaryColor: Color(0xFF42A5F5),
    textSecondaryColor: Color(0xFF90CAF9),
    speedometerColor: Color(0xFF1E88E5),
    tachometerColor: Color(0xFF42A5F5),
    successColor: Color(0xFF4CAF50),
    warningColor: Color(0xFFFF9800),
    dangerColor: Color(0xFFF44336),
    inactiveColor: Color(0xFF424242),
    shadowColor: Color(0x801E88E5),
    borderRadius: 25.0,
    borderWidth: 0.0,
    shadowBlurRadius: 16.0,
    shadowOffset: Offset(0, 6),
    fontFamily: 'serif',
    headerFontWeight: FontWeight.w700,
    bodyFontWeight: FontWeight.w500,
    iconSize: 20.0,
    containerPadding: EdgeInsets.all(24.0),
    gaugeStyle: GaugeStyle.analog,
    useGradients: true,
    showDecorations: false,
    elementSpacing: 16.0,
  );

  // Modern car theme - Sleek digital displays with metallic styling
  static const DashboardTheme modern = DashboardTheme(
    name: 'Modern',
    backgroundColor: Color(0xFF0A0A0A),
    containerColor: Color(0xFF1A1A1A),
    borderColor: Color(0xFFB0BEC5), // Metallic silver border
    primaryAccentColor: Color(0xFF00E5FF),
    secondaryAccentColor: Color(0xFF40C4FF),
    textPrimaryColor: Color(0xFFE0E0E0), // Brighter metallic text
    textSecondaryColor: Color(0xFF9E9E9E), // Metallic gray
    speedometerColor: Color(0xFF00E5FF),
    tachometerColor: Color(0xFF40C4FF),
    successColor: Color(0xFF00E676),
    warningColor: Color(0xFFFFAB00),
    dangerColor: Color(0xFFFF1744), // Only used for errors
    inactiveColor: Color(0xFF424242),
    shadowColor: Color(0x80B0BEC5), // Metallic shadow
    borderRadius: 8.0, // More angular, modern look
    borderWidth: 1.5, // Slightly thicker for metallic appearance
    shadowBlurRadius: 15.0,
    shadowOffset: Offset(0, 3),
    fontFamily: 'RobotoMono', // Monospace font for digital/tech feel
    headerFontWeight: FontWeight.w700,
    bodyFontWeight: FontWeight.w500,
    iconSize: 18.0,
    containerPadding: EdgeInsets.all(16.0),
    gaugeStyle: GaugeStyle.digital,
    useGradients: false, // Disabled to prevent crashes
    showDecorations: true,
    elementSpacing: 12.0,
  );

  // Woman theme - Elegant and sophisticated
  static const DashboardTheme woman = DashboardTheme(
    name: 'Woman',
    backgroundColor: Color(0xFF2C1810),
    containerColor: Color(0xFF3D2317),
    borderColor: Color(0xFFE91E63),
    primaryAccentColor: Color(0xFFE91E63),
    secondaryAccentColor: Color(0xFFF8BBD9),
    textPrimaryColor: Color(0xFFF8BBD9),
    textSecondaryColor: Color(0xFFBCAAA4),
    speedometerColor: Color(0xFFF8BBD9),
    tachometerColor: Color(0xFFE91E63),
    successColor: Color(0xFF81C784),
    warningColor: Color(0xFFFFB74D),
    dangerColor: Color(0xFFE57373),
    inactiveColor: Color(0xFF8D6E63),
    shadowColor: Color(0x70E91E63),
    borderRadius: 30.0,
    borderWidth: 2.0,
    shadowBlurRadius: 24.0,
    shadowOffset: Offset(0, 8),
    fontFamily: 'sans-serif',
    headerFontWeight: FontWeight.w500,
    bodyFontWeight: FontWeight.w300,
    iconSize: 19.0,
    containerPadding: EdgeInsets.all(20.0),
    gaugeStyle: GaugeStyle.elegant,
    useGradients: true,
    showDecorations: true,
    elementSpacing: 14.0,
  );

  static DashboardTheme getTheme(DashboardThemeType type) {
    switch (type) {
      case DashboardThemeType.linux:
        return linux;
      case DashboardThemeType.classic:
        return classic;
      case DashboardThemeType.modern:
        return modern;
      case DashboardThemeType.woman:
        return woman;
    }
  }

  // Helper methods for different use cases
  Color getFuelColor(double level) {
    if (level <= 15) return dangerColor;
    if (level <= 25) return warningColor;
    return successColor;
  }

  Color getTemperatureColor(double temp) {
    if (temp < 70) return secondaryAccentColor;
    if (temp > 100) return dangerColor;
    return successColor;
  }

  Color getRpmColor(double rpm) {
    if (rpm < 3000) return tachometerColor;
    if (rpm < 5000) return Color(0xFFFFEB3B);
    if (rpm < 6500) return warningColor;
    return dangerColor;
  }

  Color getTickColor(double level, double min, double max) {
    final normalized = ((level - min) / (max - min)).clamp(0.0, 1.0);
    if (normalized <= 0.25) return secondaryAccentColor;
    if (normalized <= 0.5) return successColor;
    if (normalized <= 0.75) return Color(0xFFFFEB3B);
    if (normalized <= 0.9) return warningColor;
    return dangerColor;
  }

  // Helper methods for consistent styling
  BoxDecoration getContainerDecoration() {
    return BoxDecoration(
      color: containerColor,
      border: Border.all(color: borderColor, width: borderWidth),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [BoxShadow(color: shadowColor, blurRadius: shadowBlurRadius, offset: shadowOffset)],
    );
  }

  // Metallic container decoration for Modern theme
  BoxDecoration getMetallicContainerDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF000000), // Pure black at top-left
          Color(0xFF1A1A1A), // Dark gray
          Color(0xFF2A2A2A), // Lighter dark gray
          Color(0xFF1A1A1A), // Back to dark gray for metallic effect
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      // Removed border and box shadows for clean metallic look
    );
  }

  TextStyle getHeaderTextStyle({double? fontSize, Color? color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontWeight: headerFontWeight,
      fontSize: fontSize,
      color: color ?? primaryAccentColor,
    );
  }

  TextStyle getBodyTextStyle({double? fontSize, Color? color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontWeight: bodyFontWeight,
      fontSize: fontSize,
      color: color ?? textSecondaryColor,
    );
  }
}
