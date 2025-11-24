import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/earthquake_controller.dart';
import '../widgets/earthquake_card.dart';
import '../widgets/earthquake_list_skeleton.dart';
import '../../../../core/controllers/theme_controller.dart';
import 'earthquake_detail_screen.dart';

class HomeScreen extends GetView<EarthquakeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earthquake Forecast'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Obx(
              () => Icon(
                Get.find<ThemeController>().isDarkMode.value
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
            ),
            onPressed: () => Get.find<ThemeController>().toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchAllData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (val) => controller.searchQuery.value = val,
                  decoration: InputDecoration(
                    hintText: 'Search earthquakes...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(
                    () => Row(
                      children: [
                        _buildFilterChip('All'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Near Me'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Significant'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Earthquake List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const EarthquakeListSkeleton();
              }

              if (controller.errorMessage.isNotEmpty) {
                return Center(child: Text(controller.errorMessage.value));
              }

              if (controller.filteredEarthquakes.isEmpty) {
                return const Center(child: Text('No earthquakes found.'));
              }

              return ListView.builder(
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

  Widget _buildFilterChip(String label) {
    final isSelected = controller.filterType.value == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          controller.filterType.value = label;
        }
      },
      selectedColor: Colors.redAccent,
      backgroundColor: Colors.grey[800],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[300],
      ),
    );
  }
}
