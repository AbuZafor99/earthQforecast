import 'dart:async';

import 'package:earthqforcast/core/controllers/location_controller.dart';
import 'package:earthqforcast/core/services/notification_service.dart';
import 'package:get/get.dart';

import '../../data/models/earthquake_model.dart';
import '../../data/models/news_model.dart';
import '../../data/sources/earthquake_api.dart'; // For news
import '../../domain/repositories/earthquake_repository.dart';

class EarthquakeController extends GetxController {
  final EarthquakeRepository _repository = Get.find<EarthquakeRepository>();
  final LocationController _locationController = Get.find<LocationController>();

  final RxList<EarthquakeModel> recentEarthquakes = <EarthquakeModel>[].obs;
  final RxList<EarthquakeModel> significantEarthquakes =
      <EarthquakeModel>[].obs;
  final RxList<EarthquakeModel> monthEarthquakes =
      <EarthquakeModel>[].obs; // For search and Near Me
  final RxList<NewsModel> news = <NewsModel>[].obs;

  // Filter and Search
  final RxString searchQuery = ''.obs;
  final RxString filterType = 'All'.obs; // 'All', 'Near Me', 'Significant'

  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs; // For incremental updates
  final RxString errorMessage = ''.obs;
  final RxBool isMapDarkMode = true.obs; // Default to dark mode

  // News filtering
  final RxString newsSearchQuery = ''.obs;
  final RxString selectedCountry = 'global'.obs;
  final RxList<NewsModel> forecastNews = <NewsModel>[].obs;

  Timer? _timer;
  final NotificationService _notificationService = NotificationService();

  @override
  void onInit() {
    super.onInit();
    _notificationService.init();
    fetchAllData(); // Initial load
    // Poll every 2 minutes - use background refresh mode
    _timer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => fetchAllData(isBackgroundRefresh: true),
    );

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
    // If there's a search query, search across MONTH data
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase().trim();

      // Search across month earthquakes
      final searchResults = monthEarthquakes.where((e) {
        final title = e.title.toLowerCase();
        final place = e.place.toLowerCase();

        // Check if the query contains the search term or vice versa
        final titleMatch = title.contains(query);
        final placeMatch = place.contains(query);

        // Also split query into words and check if any word matches
        final queryWords = query.split(' ');
        final anyWordMatch = queryWords.any((word) {
          if (word.length < 2) return false;
          return title.contains(word) || place.contains(word);
        });

        return titleMatch || placeMatch || anyWordMatch;
      }).toList();

      // Sort by time (most recent first)
      searchResults.sort((a, b) => b.time.compareTo(a.time));

      return searchResults;
    }

    // If no search query, apply normal filtering
    List<EarthquakeModel> list;
    if (filterType.value == 'Significant') {
      list = significantEarthquakes; // Already month data
    } else if (filterType.value == 'All') {
      list = recentEarthquakes; // 24-hour data
    } else {
      list = monthEarthquakes; // Use month data for Near Me
    }

    // Apply Filter
    if (filterType.value == 'Near Me') {
      final userPos = _locationController.currentPosition.value;
      if (userPos == null) {
        // If no location available, return empty list with a message
        print('Location not available for Near Me filter');
        return [];
      }

      // Filter earthquakes within 1000 km of user location
      list = list.where((e) {
        final distance = _locationController.calculateDistance(
          e.latitude,
          e.longitude,
        );
        return distance <= 1000; // Within 1000 km
      }).toList();

      // Sort by distance
      list.sort((a, b) {
        final distA = _locationController.calculateDistance(
          a.latitude,
          a.longitude,
        );
        final distB = _locationController.calculateDistance(
          b.latitude,
          b.longitude,
        );
        return distA.compareTo(distB);
      });
    }

    return list;
  }

  Future<void> fetchAllData({bool isBackgroundRefresh = false}) async {
    // Use isUpdating for background refresh, isLoading for initial load
    if (isBackgroundRefresh) {
      isUpdating.value = true;
    } else {
      isLoading.value = true;
    }

    errorMessage.value = '';
    try {
      // Fetch Recent
      final recentResult = await _repository.getRecentEarthquakes();
      recentResult.fold(
        (failure) => errorMessage.value = failure.message ?? 'Unknown error',
        (data) {
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
        },
      );

      // Fetch Significant (month data)
      final significantResult = await _repository.getSignificantEarthquakes();
      significantResult.fold((failure) {
        if (errorMessage.value.isEmpty)
          errorMessage.value = failure.message ?? 'Unknown error';
      }, (data) => significantEarthquakes.value = data);

      // Fetch Month Earthquakes (for search and Near Me)
      // Merge USGS month data with EMSC data for comprehensive coverage
      final monthResult = await _repository.getAllMonthEarthquakes();
      List<EarthquakeModel> allMonthData = [];

      monthResult.fold((failure) {
        if (errorMessage.value.isEmpty)
          errorMessage.value = failure.message ?? 'Unknown error';
      }, (data) => allMonthData.addAll(data));

      // Fetch EMSC data (past 30 days)
      try {
        final emscData = await Get.find<ApiService>().getEMSCEarthquakes(
          days: 30,
        );
        allMonthData.addAll(emscData);
        print('Fetched ${emscData.length} earthquakes from EMSC');
      } catch (e) {
        print('Error fetching EMSC data: $e');
      }

      // Deduplicate combined data
      final deduplicatedData = Get.find<ApiService>().deduplicateEarthquakes(
        allMonthData,
      );
      monthEarthquakes.value = deduplicatedData;
      print(
        'Total earthquakes after deduplication: ${deduplicatedData.length}',
      );

      // Fetch News
      try {
        final newsData = await Get.find<ApiService>().getEarthquakeNews(
          country: selectedCountry.value,
        );
        news.value = newsData;

        // Fetch Forecast News
        final forecastData = await Get.find<ApiService>().getForecastNews(
          country: selectedCountry.value,
        );
        forecastNews.value = forecastData;
      } catch (e) {
        print("Error fetching news: $e");
      }
    } catch (e) {
      errorMessage.value = 'Failed to load data: $e';
    } finally {
      // Reset both flags
      isLoading.value = false;
      isUpdating.value = false;
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

  // Filtered news based on search query
  List<NewsModel> get filteredNews {
    if (newsSearchQuery.value.isEmpty) return news;

    final query = newsSearchQuery.value.toLowerCase();
    return news.where((n) {
      return n.title.toLowerCase().contains(query) ||
          n.description.toLowerCase().contains(query) ||
          n.sourceName.toLowerCase().contains(query);
    }).toList();
  }

  // Filtered forecast news based on search query
  List<NewsModel> get filteredForecastNews {
    if (newsSearchQuery.value.isEmpty) return forecastNews;

    final query = newsSearchQuery.value.toLowerCase();
    return forecastNews.where((n) {
      return n.title.toLowerCase().contains(query) ||
          n.description.toLowerCase().contains(query) ||
          n.sourceName.toLowerCase().contains(query);
    }).toList();
  }

  // Refresh news with current country filter
  Future<void> refreshNews() async {
    try {
      final newsData = await Get.find<ApiService>().getEarthquakeNews(
        country: selectedCountry.value,
      );
      news.value = newsData;

      final forecastData = await Get.find<ApiService>().getForecastNews(
        country: selectedCountry.value,
      );
      forecastNews.value = forecastData;
    } catch (e) {
      print("Error refreshing news: $e");
    }
  }
}
