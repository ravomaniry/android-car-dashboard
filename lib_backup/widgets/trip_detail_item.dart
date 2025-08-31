import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TripDetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const TripDetailItem({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(
          color: const Color(0xFF00D9FF), // Cyan for trip details
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D9FF).withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF00D9FF), // Cyan for icons
            size: 18,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.firaCode(
              color: const Color(0xFF888888),
              fontSize: 8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.firaCode(
              color: const Color(0xFF00D9FF), // Cyan for values
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
