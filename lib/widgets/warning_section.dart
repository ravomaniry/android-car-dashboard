import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WarningSection extends StatelessWidget {
  final bool oilWarning;
  final Animation<double> blinkAnimation;

  const WarningSection({
    super.key,
    required this.oilWarning,
    required this.blinkAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(
          color: const Color(0xFF00FF41),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF41).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.terminal,
                color: const Color(0xFF00FF41),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'SYSTEM STATUS',
                style: GoogleFonts.firaCode(
                  color: const Color(0xFF00FF41),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Warning indicators
          Expanded(
            child: Column(
              children: [
                _buildWarningItem(
                  'OIL',
                  oilWarning,
                  Icons.opacity,
                  'PRESSURE OK',
                  'LOW PRESSURE',
                ),
                const SizedBox(height: 12),
                _buildWarningItem(
                  'BATTERY',
                  false,
                  Icons.battery_full,
                  'VOLTAGE OK',
                  'LOW VOLTAGE',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(
    String label,
    bool isWarning,
    IconData icon,
    String okMessage,
    String warningMessage,
  ) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isWarning ? Colors.red : const Color(0xFF333333),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: blinkAnimation,
            builder: (context, child) {
              return Icon(
                icon,
                color: isWarning
                    ? Color.lerp(
                        Colors.red.withOpacity(0.3),
                        Colors.red,
                        blinkAnimation.value,
                      )
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
                  style: GoogleFonts.firaCode(
                    color: isWarning ? Colors.red : const Color(0xFF888888),
                    fontSize: 8,
                  ),
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
                    color: Color.lerp(
                      Colors.red.withOpacity(0.3),
                      Colors.red,
                      blinkAnimation.value,
                    ),
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
