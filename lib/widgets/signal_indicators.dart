import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignalIndicators extends StatelessWidget {
  final bool leftTurnSignal;
  final bool rightTurnSignal;
  final bool hazardLights;
  final Animation<double> blinkAnimation;
  final bool isCompact;

  const SignalIndicators({
    super.key,
    required this.leftTurnSignal,
    required this.rightTurnSignal,
    required this.hazardLights,
    required this.blinkAnimation,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Row(
        children: [
          Expanded(child: _buildCompactSignalIndicator('L', Icons.keyboard_arrow_left, leftTurnSignal || hazardLights)),
          const SizedBox(width: 4),
          Expanded(child: _buildCompactSignalIndicator('HAZ', Icons.warning, hazardLights)),
          const SizedBox(width: 4),
          Expanded(
            child: _buildCompactSignalIndicator('R', Icons.keyboard_arrow_right, rightTurnSignal || hazardLights),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SIGNAL INDICATORS',
          style: GoogleFonts.firaCode(color: const Color(0xFF888888), fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
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
            Expanded(child: _buildSignalIndicator('HAZ', 'Hazard Lights', Icons.warning, hazardLights, hazardLights)),
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
    );
  }

  Widget _buildSignalIndicator(String label, String description, IconData icon, bool isOn, bool shouldBlink) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isOn ? Colors.orange : const Color(0xFF333333), width: 1),
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
                        ? Color.lerp(Colors.orange.withValues(alpha: 0.3), Colors.orange, blinkAnimation.value)
                        : Colors.orange)
                  : const Color(0xFF333333);

              return Icon(icon, color: color, size: 16);
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

  Widget _buildCompactSignalIndicator(String label, IconData icon, bool isOn) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isOn ? Colors.orange : const Color(0xFF333333), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isOn ? Colors.orange : const Color(0xFF333333), size: 12),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.firaCode(
                color: isOn ? Colors.orange : const Color(0xFF666666),
                fontSize: 6,
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
