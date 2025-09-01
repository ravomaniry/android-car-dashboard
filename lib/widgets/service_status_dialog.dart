import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/event_manager.dart';

class ServiceStatusDialog<T> extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget leftContent;
  final List<T> events;
  final List<Widget>? actions;

  const ServiceStatusDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.leftContent,
    required this.events,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width * 0.8;
    // Subtract estimated title (56px) and buttons (52px) height
    final dialogHeight = screenSize.height * 0.9 - 108;

    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: Row(
        children: [
          Icon(icon, color: const Color(0xFF00D9FF)),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.firaCode(color: const Color(0xFF00D9FF), fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Row(
          children: [
            // Left column: General status
            Expanded(
              flex: 1,
              child: Container(
                height: dialogHeight,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F0F),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00D9FF), width: 1),
                ),
                child: SingleChildScrollView(child: leftContent),
              ),
            ),

            // Right column: Logs
            Expanded(
              flex: 1,
              child: Container(
                height: dialogHeight,
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F0F),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00D9FF), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest Events (10):',
                      style: GoogleFonts.firaCode(
                        color: const Color(0xFF00D9FF),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF000000),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: events.map((event) {
                              if (event is GpsEvent) {
                                return _buildEventEntry(event.message, event.level, event.timestamp);
                              } else if (event is BluetoothEvent) {
                                return _buildEventEntry(event.message, event.level, event.timestamp);
                              }
                              return const SizedBox.shrink();
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: actions,
    );
  }

  Widget _buildEventEntry(String message, String level, DateTime timestamp) {
    Color levelColor;
    switch (level) {
      case 'INFO':
        levelColor = const Color(0xFF00D9FF);
        break;
      case 'STATUS':
        levelColor = const Color(0xFF00FF41);
        break;
      case 'CONFIG':
        levelColor = const Color(0xFFFF9800);
        break;
      case 'TRIP':
        levelColor = const Color(0xFFE91E63);
        break;
      case 'DATA':
        levelColor = const Color(0xFF9C27B0);
        break;
      case 'ERROR':
        levelColor = const Color(0xFFFF5722);
        break;
      default:
        levelColor = const Color(0xFF888888);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: levelColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
            child: Text(
              level,
              style: GoogleFonts.firaCode(color: levelColor, fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: GoogleFonts.firaCode(color: Colors.white, fontSize: 10)),
          ),
          const SizedBox(width: 8),
          Text(
            '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
            style: GoogleFonts.firaCode(color: const Color(0xFF666666), fontSize: 8),
          ),
        ],
      ),
    );
  }
}
