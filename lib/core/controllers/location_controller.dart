import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationController extends GetxController {
  final LocationService _locationService = LocationService();

  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getUserLocation();
  }

  Future<void> getUserLocation() async {
    isLoading.value = true;
    error.value = '';
    try {
      final position = await _locationService.getCurrentLocation();
      currentPosition.value = position;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Rx<Position?> get userLocation => currentPosition;

  double calculateDistance(double lat, double lng) {
    if (currentPosition.value == null) return 0.0;
    return Geolocator.distanceBetween(
          currentPosition.value!.latitude,
          currentPosition.value!.longitude,
          lat,
          lng,
        ) /
        1000; // Return in km
  }
}
