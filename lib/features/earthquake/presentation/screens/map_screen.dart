import 'dart:ui';

import 'package:earthqforcast/core/controllers/location_controller.dart';
import 'package:earthqforcast/core/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/earthquake_model.dart';
import '../controllers/earthquake_controller.dart';

class MapScreen extends GetView<EarthquakeController> {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<LocationController>();
    final themeController = Get.find<ThemeController>();
    final mapController = MapController();
    final searchController = TextEditingController();
    final selectedRegion = 'World'.obs;
    bool hasCentered = false;

    // Region coordinates
    final Map<String, Map<String, double>> regions = {
      'World': {'lat': 20.0, 'lng': 0.0, 'zoom': 2.0},
      'Asia': {'lat': 34.0, 'lng': 100.0, 'zoom': 3.5},
      'Europe': {'lat': 54.0, 'lng': 15.0, 'zoom': 4.0},
      'Americas': {'lat': 15.0, 'lng': -90.0, 'zoom': 3.0},
      'Africa': {'lat': 0.0, 'lng': 20.0, 'zoom': 3.5},
      'Oceania': {'lat': -25.0, 'lng': 140.0, 'zoom': 4.0},
    };

    // Listen for location updates to center map initially
    ever(locationController.currentPosition, (pos) {
      if (pos != null && !hasCentered) {
        mapController.move(LatLng(pos.latitude, pos.longitude), 5.0);
        hasCentered = true;
      }
    });

    void searchLocation(String query) {
      if (query.isEmpty) return;

      // Search in earthquake data for matching location
      final results = controller.recentEarthquakes.where((eq) {
        return eq.place.toLowerCase().contains(query.toLowerCase()) ||
            eq.title.toLowerCase().contains(query.toLowerCase());
      }).toList();

      if (results.isNotEmpty) {
        final firstResult = results.first;
        mapController.move(
          LatLng(firstResult.latitude, firstResult.longitude),
          8.0,
        );
        Get.snackbar(
          'Location Found',
          'Moved to ${firstResult.place}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Not Found',
          'No earthquakes found near "$query"',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    }

    return Scaffold(
      body: Obx(() {
        final userPos = locationController.currentPosition.value;
        final initialCenter = userPos != null
            ? LatLng(userPos.latitude, userPos.longitude)
            : const LatLng(20.0, 0.0);

        return Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: 3.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onMapReady: () {
                  if (userPos != null && !hasCentered) {
                    mapController.move(
                      LatLng(userPos.latitude, userPos.longitude),
                      5.0,
                    );
                    hasCentered = true;
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: themeController.isDarkMode.value
                      ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: themeController.isDarkMode.value
                      ? const ['a', 'b', 'c', 'd']
                      : const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.earthqforcast.app',
                ),
                MarkerLayer(
                  markers: [
                    // User Location Marker
                    if (userPos != null)
                      Marker(
                        point: LatLng(userPos.latitude, userPos.longitude),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 30,
                        ),
                      ),
                    // Earthquake Markers
                    ...controller.recentEarthquakes.map(
                      (e) => _buildEarthquakeMarker(context, e),
                    ),
                  ],
                ),
              ],
            ),
            // Modern Search Bar with Region Filter
            Positioned(
              top: 60,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  // Search Bar
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: themeController.isDarkMode.value
                              ? [
                                  const Color(0xFF374151).withOpacity(0.9),
                                  const Color(0xFF1F2937).withOpacity(0.95),
                                ]
                              : [
                                  Colors.white.withOpacity(0.9),
                                  Colors.grey[50]!.withOpacity(0.85),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: themeController.isDarkMode.value
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              themeController.isDarkMode.value ? 0.3 : 0.1,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: TextField(
                            controller: searchController,
                            style: TextStyle(
                              color: themeController.isDarkMode.value
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search location...',
                              hintStyle: TextStyle(
                                color: themeController.isDarkMode.value
                                    ? Colors.white54
                                    : Colors.black45,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: themeController.isDarkMode.value
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                              suffixIcon: searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear_rounded,
                                        color: themeController.isDarkMode.value
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                      onPressed: () => searchController.clear(),
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            onSubmitted: searchLocation,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Region Filter Dropdown
                  Expanded(
                    flex: 2,
                    child: Obx(
                      () => Container(
                        height: 56, // Match search bar height
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: themeController.isDarkMode.value
                                ? [
                                    const Color(0xFF374151).withOpacity(0.9),
                                    const Color(0xFF1F2937).withOpacity(0.95),
                                  ]
                                : [
                                    Colors.white.withOpacity(0.9),
                                    Colors.grey[50]!.withOpacity(0.85),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: themeController.isDarkMode.value
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                themeController.isDarkMode.value ? 0.3 : 0.1,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                              spreadRadius: -5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedRegion.value,
                                isExpanded: true,
                                icon: Icon(
                                  Icons.arrow_drop_down_rounded,
                                  color: themeController.isDarkMode.value
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                                dropdownColor: themeController.isDarkMode.value
                                    ? const Color(0xFF1F2937)
                                    : Colors.white,
                                style: TextStyle(
                                  color: themeController.isDarkMode.value
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 14,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                items: regions.keys.map((String region) {
                                  return DropdownMenuItem<String>(
                                    value: region,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.public_rounded,
                                          size: 18,
                                          color:
                                              themeController.isDarkMode.value
                                              ? Colors.white70
                                              : Colors.black54,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(region),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    selectedRegion.value = newValue;
                                    final regionData = regions[newValue]!;
                                    mapController.move(
                                      LatLng(
                                        regionData['lat']!,
                                        regionData['lng']!,
                                      ),
                                      regionData['zoom']!,
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Day/Night Mode Toggle
            // Zoom Controls
            Positioned(
              bottom: 100,
              right: 16,
              child: Column(
                children: [
                  _buildGlossyButton(
                    icon: Icons.add_rounded,
                    onTap: () {
                      final currentZoom = mapController.camera.zoom;
                      mapController.move(
                        mapController.camera.center,
                        currentZoom + 1,
                      );
                    },
                    context: context,
                  ),
                  const SizedBox(height: 12),
                  _buildGlossyButton(
                    icon: Icons.remove_rounded,
                    onTap: () {
                      final currentZoom = mapController.camera.zoom;
                      mapController.move(
                        mapController.camera.center,
                        currentZoom - 1,
                      );
                    },
                    context: context,
                  ),
                ],
              ),
            ),
            _buildRecenterButton(mapController, locationController),
          ],
        );
      }),
    );
  }

  Widget _buildRecenterButton(
    MapController mapController,
    LocationController locationController,
  ) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        heroTag: 'recenter_btn',
        onPressed: () {
          final userPos = locationController.currentPosition.value;
          if (userPos != null) {
            mapController.move(
              LatLng(userPos.latitude, userPos.longitude),
              5.0,
            );
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Marker _buildEarthquakeMarker(BuildContext context, EarthquakeModel e) {
    Color color;
    double size;

    if (e.magnitude >= 6.0) {
      color = const Color(0xFFEF4444); // Red
      size = 40.0;
    } else if (e.magnitude >= 4.0) {
      color = const Color(0xFFF59E0B); // Orange
      size = 30.0;
    } else {
      color = const Color(0xFF10B981); // Green
      size = 20.0;
    }

    return Marker(
      point: LatLng(e.latitude, e.longitude),
      width: size,
      height: size,
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Theme.of(context).colorScheme.surface,
            builder: (_) => Container(
              padding: const EdgeInsets.all(16),
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Magnitude: ${e.magnitude}'),
                  Text('Depth: ${e.depth} km'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.7),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildGlossyButton({
    required IconData icon,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF1F2937).withOpacity(0.9),
                    const Color(0xFF111827).withOpacity(0.95),
                  ]
                : [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.7),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : Colors.black87,
          size: 24,
        ),
      ),
    );
  }
}
