import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/continent_utils.dart';

class LocationService {
  static const String _continentKey = 'user_continent';

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    final position = await Geolocator.getCurrentPosition();

    // Detect and cache continent
    await _detectAndCacheContinent(position);

    return position;
  }

  /// Detect continent from position and cache it
  Future<void> _detectAndCacheContinent(Position position) async {
    try {
      final continent = ContinentUtils.detectContinent(
        position.latitude,
        position.longitude,
      );
      await _cacheContinent(continent);
    } catch (e) {
      print('Error detecting continent: $e');
    }
  }

  /// Cache continent in shared preferences
  Future<void> _cacheContinent(String continent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_continentKey, continent);
    } catch (e) {
      print('Error caching continent: $e');
    }
  }

  /// Get cached continent from shared preferences
  static Future<String?> getCachedContinent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_continentKey);
    } catch (e) {
      print('Error getting cached continent: $e');
      return null;
    }
  }

  /// Get continent from coordinates
  String getContinentFromCoordinates(double latitude, double longitude) {
    return ContinentUtils.detectContinent(latitude, longitude);
  }
}
