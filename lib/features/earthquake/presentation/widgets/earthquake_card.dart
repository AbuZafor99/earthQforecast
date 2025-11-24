import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../data/models/earthquake_model.dart';
import '../controllers/earthquake_controller.dart';
import 'dart:ui';

class EarthquakeCard extends StatelessWidget {
  final EarthquakeModel earthquake;

  const EarthquakeCard({super.key, required this.earthquake});

  Color _getMagnitudeColor(double mag) {
    if (mag >= 6.0) return const Color(0xFFEF4444); // Red
    if (mag >= 4.0) return const Color(0xFFF59E0B); // Orange
    return const Color(0xFF10B981); // Green
  }

  LinearGradient _getMagnitudeGradient(double mag) {
    if (mag >= 6.0) {
      return const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (mag >= 4.0) {
      return const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFF10B981), Color(0xFF059669)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EarthquakeController>();
    final distance = controller.getDistanceFromUser(
      earthquake.latitude,
      earthquake.longitude,
    );

    final date = DateTime.fromMillisecondsSinceEpoch(earthquake.time);
    final formattedDate = DateFormat('MMM d, h:mm a').format(date);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1F2937).withOpacity(0.8),
                  const Color(0xFF111827).withOpacity(0.9),
                ]
              : [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _getMagnitudeColor(earthquake.magnitude).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: _getMagnitudeColor(
                  earthquake.magnitude,
                ).withOpacity(0.3),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                // Magnitude Badge with Gradient
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: _getMagnitudeGradient(earthquake.magnitude),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _getMagnitudeColor(
                          earthquake.magnitude,
                        ).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        earthquake.magnitude.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          shadows: [
                            Shadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                      ),
                      const Text(
                        'MAG',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        earthquake.place,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // Info Row
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _buildInfoChip(
                            Icons.access_time_rounded,
                            formattedDate,
                            isDark,
                          ),
                          if (distance > 0)
                            _buildInfoChip(
                              Icons.location_on_rounded,
                              '${distance.toStringAsFixed(0)} km',
                              isDark,
                            ),
                          _buildInfoChip(
                            Icons.layers_rounded,
                            '${earthquake.depth.toStringAsFixed(1)} km',
                            isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDark ? Colors.white70 : Colors.black54),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
