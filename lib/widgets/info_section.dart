import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoSection extends StatelessWidget {
  final bool drlOn;
  final bool lowBeamOn;
  final bool highBeamOn;
  final bool leftTurnSignal;
  final bool rightTurnSignal;
  final bool hazardLights;
  final Animation<double> blinkAnimation;

  const InfoSection({
    super.key,
    required this.drlOn,
    required this.lowBeamOn,
    required this.highBeamOn,
    required this.leftTurnSignal,
    required this.rightTurnSignal,
    required this.hazardLights,
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
                Icons.info_outline,
                color: const Color(0xFF00FF41),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'VEHICLE STATUS',
                style: GoogleFonts.firaCode(
                  color: const Color(0xFF00FF41),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lighting section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LIGHTING SYSTEMS',
                  style: GoogleFonts.firaCode(
                    color: const Color(0xFF888888),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Light indicators in a row
                Row(
                  children: [
                    Expanded(
                      child: _buildLightIndicator(
                        'DRL',
                        'Daytime Running Lights',
                        Icons.wb_sunny,
                        drlOn,
                        false,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildLightIndicator(
                        'LOW',
                        'Low Beam Headlights',
                        Icons.lightbulb_outline,
                        lowBeamOn,
                        false,
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
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  'SIGNAL INDICATORS',
                  style: GoogleFonts.firaCode(
                    color: const Color(0xFF888888),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Turn signals in a row (L - HAZ - R)
                Row(
                  children: [
                    Expanded(
                      child: _buildSignalIndicator(
                        'L',
                        'Left Turn',
                        Icons.keyboard_arrow_left,
                        leftTurnSignal || hazardLights,
                        leftTurnSignal || hazardLights,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSignalIndicator(
                        'HAZ',
                        'Hazard Lights',
                        Icons.warning,
                        hazardLights,
                        hazardLights,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSignalIndicator(
                        'R',
                        'Right Turn',
                        Icons.keyboard_arrow_right,
                        rightTurnSignal || hazardLights,
                        rightTurnSignal || hazardLights,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color(0xFF333333),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ALL SYSTEMS',
                  style: GoogleFonts.firaCode(
                    color: const Color(0xFF00FF41),
                    fontSize: 10,
                  ),
                ),
                AnimatedBuilder(
                  animation: blinkAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          const Color(0xFF00FF41).withOpacity(0.3),
                          const Color(0xFF00FF41),
                          blinkAnimation.value,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLightIndicator(
    String label,
    String description,
    IconData icon,
    bool isOn,
    bool shouldBlink,
  ) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isOn ? const Color(0xFF00FF41) : const Color(0xFF333333),
          width: 1,
        ),
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
                          const Color(0xFF00FF41).withOpacity(0.3),
                          const Color(0xFF00FF41),
                          blinkAnimation.value,
                        )
                      : const Color(0xFF00FF41))
                  : const Color(0xFF333333);

              return Icon(
                icon,
                color: color,
                size: 14,
              );
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
              style: GoogleFonts.firaCode(
                color: isOn ? const Color(0xFF888888) : const Color(0xFF444444),
                fontSize: 6,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalIndicator(
    String label,
    String description,
    IconData icon,
    bool isOn,
    bool shouldBlink,
  ) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isOn ? Colors.orange : const Color(0xFF333333),
          width: 1,
        ),
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
                          Colors.orange.withOpacity(0.3),
                          Colors.orange,
                          blinkAnimation.value,
                        )
                      : Colors.orange)
                  : const Color(0xFF333333);

              return Icon(
                icon,
                color: color,
                size: 16,
              );
            },
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.firaCode(
                color: isOn ? Colors.orange : const Color(0xFF666666),
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
