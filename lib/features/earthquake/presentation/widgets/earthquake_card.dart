import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../data/models/earthquake_model.dart';
import '../controllers/earthquake_controller.dart';

class EarthquakeCard extends StatelessWidget {
  final EarthquakeModel earthquake;

  const EarthquakeCard({super.key, required this.earthquake});

  Color _getMagnitudeColor(double mag) {
    if (mag >= 6.0) return const Color(0xFFEF4444); // Red
    if (mag >= 4.0) return const Color(0xFFF59E0B); // Orange
    return const Color(0xFF10B981); // Green
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getMagnitudeColor(earthquake.magnitude).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                earthquake.magnitude.toStringAsFixed(1),
                style: TextStyle(
                  color: _getMagnitudeColor(earthquake.magnitude),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  earthquake.place,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    if (distance > 0) ...[
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${distance.toStringAsFixed(0)} km',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
