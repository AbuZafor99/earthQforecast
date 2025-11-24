import 'package:get/get.dart';

import '../../data/models/earthquake_model.dart';
import '../../data/models/news_model.dart';
import '../../domain/repositories/earthquake_repository.dart';
import '../../data/sources/earthquake_api.dart'; // For news
import 'package:earthqforcast/core/controllers/location_controller.dart';
import 'dart:async';
import 'package:earthqforcast/core/services/notification_service.dart';

class EarthquakeController extends GetxController {
  final EarthquakeRepository _repository = Get.find<EarthquakeRepository>();
  final LocationController _locationController = Get.find<LocationController>();

  final RxList<EarthquakeModel> recentEarthquakes = <EarthquakeModel>[].obs;
  final RxList<EarthquakeModel> significantEarthquakes =
      <EarthquakeModel>[].obs;
  final RxList<NewsModel> news = <NewsModel>[].obs;

  // Filter and Search
  final RxString searchQuery = ''.obs;
  final RxString filterType = 'All'.obs; // 'All', 'Near Me', 'Significant'

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isMapDarkMode = true.obs; // Default to dark mode

  Timer? _timer;
  final NotificationService _notificationService = NotificationService();

  @override
  void onInit() {
    super.onInit();
    _notificationService.init();
    fetchAllData();
    // Poll every 2 minutes
    _timer = Timer.periodic(const Duration(minutes: 2), (_) => fetchAllData());

    // Listen to location changes to resort if needed
    // Listen to location changes to resort if needed
    // ever(_locationController.currentPosition, (_) {
    //   if (recentEarthquakes.isNotEmpty) {
    //     _sortRecentByDistance();
    //   }
    // });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  List<EarthquakeModel> get filteredEarthquakes {
    List<EarthquakeModel> list;
    if (filterType.value == 'Significant') {
      list = significantEarthquakes;
    } else {
      list = recentEarthquakes;
    }

    // Apply Search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      list = list.where((e) {
        final titleMatch = e.title.toLowerCase().contains(query);
        final placeMatch = e.place.toLowerCase().contains(query);
        return titleMatch || placeMatch;
      }).toList();
    }

    // Apply 'Near Me' filter (e.g., within 1000km)
    // Apply 'Near Me' filter (e.g., within 1000km)
    if (filterType.value == 'Near Me') {
      if (_locationController.userLocation.value != null) {
        list = list.where((e) {
          final dist = _locationController.calculateDistance(
            e.latitude,
            e.longitude,
          );
          return dist < 1000; // 1000 km radius
        }).toList();
      } else {
        // If location is not available, return empty list for "Near Me"
        // Or handle it in UI. For now, empty list to avoid confusion.
        list = [];
      }
    }

    return list;
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      // Fetch Recent
      final recentResult = await _repository.getRecentEarthquakes();
      recentResult.fold((failure) => errorMessage.value = failure.message, (
        data,
      ) {
        // Check for new earthquakes compared to current list
        if (recentEarthquakes.isNotEmpty && data.isNotEmpty) {
          final latestId = data.first.id;
          final currentLatestId = recentEarthquakes.first.id;

          if (latestId != currentLatestId) {
            _notificationService.showNotification(
              id: 1,
              title: 'New Earthquake Detected',
              body: '${data.first.title}',
            );
          }
        }

        recentEarthquakes.value = data;
        _sortByTime();
        checkForNearbyEarthquakes(data);
      });

      // Fetch Significant
      final significantResult = await _repository.getSignificantEarthquakes();
      significantResult.fold((failure) {
        if (errorMessage.value.isEmpty) errorMessage.value = failure.message;
      }, (data) => significantEarthquakes.value = data);

      // Fetch News
      try {
        final newsData = await Get.find<ApiService>().getEarthquakeNews();
        news.value = newsData;
      } catch (e) {
        print("Error fetching news: $e");
      }
    } catch (e) {
      errorMessage.value = 'Failed to load data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void _sortByTime() {
    recentEarthquakes.sort((a, b) => b.time.compareTo(a.time));
    significantEarthquakes.sort((a, b) => b.time.compareTo(a.time));
  }

  void checkForNearbyEarthquakes(List<EarthquakeModel> earthquakes) {
    final userPos = _locationController.currentPosition.value;
    if (userPos == null || earthquakes.isEmpty) return;

    // Check if the closest earthquake is within 100km
    // Since list is sorted, first is closest
    final closest = earthquakes.first;
    final distance = _locationController.calculateDistance(
      closest.latitude,
      closest.longitude,
    );

    if (distance < 100) {
      // 100 km
      _notificationService.showNotification(
        id: 2,
        title: 'Earthquake Nearby!',
        body: '${closest.title} is ${distance.toStringAsFixed(1)}km away.',
      );
    }
  }

  double getDistanceFromUser(double lat, double lng) {
    return _locationController.calculateDistance(lat, lng);
  }
}
