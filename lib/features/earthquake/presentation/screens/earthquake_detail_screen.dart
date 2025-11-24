import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/earthquake_model.dart';

class EarthquakeDetailScreen extends StatelessWidget {
  final EarthquakeModel earthquake;

  const EarthquakeDetailScreen({super.key, required this.earthquake});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(earthquake.time);
    final formattedDate = DateFormat.yMMMd().add_jm().format(date);

    return Scaffold(
      appBar: AppBar(title: const Text('Earthquake Details')),
      body: Column(
        children: [
          // Map Section
          SizedBox(
            height: 300,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  earthquake.latitude,
                  earthquake.longitude,
                ),
                initialZoom: 6.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.earthqforcast',
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(earthquake.latitude, earthquake.longitude),
                      color: Colors.red.withOpacity(0.5),
                      borderColor: Colors.red,
                      borderStrokeWidth: 2,
                      radius:
                          earthquake.magnitude *
                          10000, // Scale radius by magnitude (approx)
                      useRadiusInMeter: true,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(earthquake.latitude, earthquake.longitude),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Details Section
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      earthquake.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      context,
                      Icons.analytics,
                      'Magnitude',
                      '${earthquake.magnitude}',
                    ),
                    _buildDetailRow(
                      context,
                      Icons.layers,
                      'Depth',
                      '${earthquake.depth} km',
                    ),
                    _buildDetailRow(
                      context,
                      Icons.access_time,
                      'Time',
                      formattedDate,
                    ),
                    _buildDetailRow(
                      context,
                      Icons.location_on,
                      'Coordinates',
                      '${earthquake.latitude.toStringAsFixed(4)}, ${earthquake.longitude.toStringAsFixed(4)}',
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Safety Tips:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('• Drop, Cover, and Hold On.'),
                    const Text('• Stay away from windows and heavy furniture.'),
                    const Text(
                      '• If outdoors, move to an open area away from buildings.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
