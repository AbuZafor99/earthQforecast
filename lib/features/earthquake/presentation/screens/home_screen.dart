import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/theme_controller.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../controllers/earthquake_controller.dart';
import '../widgets/earthquake_card.dart';
import '../widgets/earthquake_list_skeleton.dart';
import 'earthquake_detail_screen.dart';

class HomeScreen extends GetView<EarthquakeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earthquake Forecast'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Obx(
              () => Icon(
                Get.find<ThemeController>().isDarkMode.value
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
            ),
            onPressed: () => Get.find<ThemeController>().toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.fetchAllData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section with Glossy Design
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF1F2937).withOpacity(0.5),
                        const Color(0xFF111827).withOpacity(0.3),
                      ]
                    : [
                        Colors.white.withOpacity(0.5),
                        Colors.grey[100]!.withOpacity(0.3),
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  children: [
                    // Glossy Search Bar
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF374151).withOpacity(0.8),
                                  const Color(0xFF1F2937).withOpacity(0.9),
                                ]
                              : [
                                  Colors.white.withOpacity(0.9),
                                  Colors.grey[50]!.withOpacity(0.8),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (val) => controller.searchQuery.value = val,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search earthquakes...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    color: isDark ? Colors.white70 : Colors.black54,
                                  ),
                                  onPressed: () => controller.searchQuery.value = '',
                                )
                              : const SizedBox.shrink()),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Animated Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Obx(
                        () => Row(
                          children: [
                            _buildGlossyFilterChip('All', context),
                            const SizedBox(width: 12),
                            _buildGlossyFilterChip('Near Me', context),
                            const SizedBox(width: 12),
                            _buildGlossyFilterChip('Significant', context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Earthquake List with Smart Updates
          Expanded(
            child: Obx(() {
              // Show skeleton loader at top when updating
              if (controller.isUpdating.value) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SkeletonLoader(),
                    ...controller.filteredEarthquakes.map(
                      (earthquake) => GestureDetector(
                        onTap: () => Get.to(
                          () => EarthquakeDetailScreen(earthquake: earthquake),
                        ),
                        child: EarthquakeCard(earthquake: earthquake),
                      ),
                    ),
                  ],
                );
              }

              if (controller.isLoading.value) {
                return const EarthquakeListSkeleton();
              }

              if (controller.errorMessage.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              if (controller.filteredEarthquakes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No earthquakes found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredEarthquakes.length,
                itemBuilder: (context, index) {
                  final earthquake = controller.filteredEarthquakes[index];
                  return GestureDetector(
                    onTap: () => Get.to(
                      () => EarthquakeDetailScreen(earthquake: earthquake),
                    ),
                    child: EarthquakeCard(earthquake: earthquake),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGlossyFilterChip(String label, BuildContext context) {
    final isSelected = controller.filterType.value == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: () => controller.filterType.value = label,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF374151).withOpacity(0.6),
                            const Color(0xFF1F2937).withOpacity(0.7),
                          ]
                        : [
                            Colors.white.withOpacity(0.8),
                            Colors.grey[100]!.withOpacity(0.6),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.blue.withOpacity(0.5)
                  : isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
              width: 1.5,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: Colors.blue.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label == 'Near Me')
                Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? Colors.white70
                          : Colors.black54,
                ),
              if (label == 'Significant')
                Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? Colors.white70
                          : Colors.black54,
                ),
              if (label != 'All') const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? Colors.white70
                          : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = controller.filterType.value == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          controller.filterType.value = label;
        }
      },
      selectedColor: Colors.blue,
      backgroundColor: Colors.grey[800],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[400],
      ),
    );
  }
}
