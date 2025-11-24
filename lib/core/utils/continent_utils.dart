/// Utility class for detecting continents from geographical coordinates
class ContinentUtils {
  /// Enum representing different continents
  static const String africa = 'Africa';
  static const String antarctica = 'Antarctica';
  static const String asia = 'Asia';
  static const String europe = 'Europe';
  static const String northAmerica = 'North America';
  static const String southAmerica = 'South America';
  static const String oceania = 'Oceania';
  static const String unknown = 'Unknown';

  /// Detect continent from latitude and longitude coordinates
  /// Uses simplified geographical boundaries for continent detection
  static String detectContinent(double latitude, double longitude) {
    // Antarctica
    if (latitude < -60) {
      return antarctica;
    }

    // Africa
    if (_isInAfrica(latitude, longitude)) {
      return africa;
    }

    // Europe
    if (_isInEurope(latitude, longitude)) {
      return europe;
    }

    // Asia
    if (_isInAsia(latitude, longitude)) {
      return asia;
    }

    // North America
    if (_isInNorthAmerica(latitude, longitude)) {
      return northAmerica;
    }

    // South America
    if (_isInSouthAmerica(latitude, longitude)) {
      return southAmerica;
    }

    // Oceania (Australia, New Zealand, Pacific Islands)
    if (_isInOceania(latitude, longitude)) {
      return oceania;
    }

    // Default to unknown for ocean coordinates
    return unknown;
  }

  /// Check if coordinates are in Africa
  static bool _isInAfrica(double lat, double lng) {
    // Approximate boundaries: 37°N to 35°S, 18°W to 52°E
    return lat >= -35 && lat <= 37 && lng >= -18 && lng <= 52;
  }

  /// Check if coordinates are in Europe
  static bool _isInEurope(double lat, double lng) {
    // Approximate boundaries: 36°N to 71°N, 10°W to 60°E
    // Exclude Asia by longitude
    return lat >= 36 &&
        lat <= 71 &&
        lng >= -10 &&
        lng <= 60 &&
        !_isInAsia(lat, lng);
  }

  /// Check if coordinates are in Asia
  static bool _isInAsia(double lat, double lng) {
    // Approximate boundaries: -10°S to 77°N, 26°E to 180°E
    // Complex boundary with Europe around Ural Mountains (~60°E)
    if (lat >= -10 && lat <= 77) {
      // Eastern boundary of Europe/Western boundary of Asia
      if (lat >= 36 && lng >= 60 && lng <= 180) {
        return true;
      }
      // Southeast Asia and Indian subcontinent
      if (lat >= -10 && lat < 36 && lng >= 60 && lng <= 180) {
        return true;
      }
      // Middle East
      if (lat >= 12 && lat <= 42 && lng >= 26 && lng < 60) {
        return true;
      }
    }
    return false;
  }

  /// Check if coordinates are in North America
  static bool _isInNorthAmerica(double lat, double lng) {
    // Approximate boundaries: 7°N to 83°N, 168°W to 52°W
    // Also includes Central America and Caribbean
    return lat >= 7 && lat <= 83 && lng >= -168 && lng <= -52;
  }

  /// Check if coordinates are in South America
  static bool _isInSouthAmerica(double lat, double lng) {
    // Approximate boundaries: 12°N to 56°S, 81°W to 35°W
    return lat >= -56 && lat <= 12 && lng >= -81 && lng <= -35;
  }

  /// Check if coordinates are in Oceania
  static bool _isInOceania(double lat, double lng) {
    // Australia: 10°S to 44°S, 113°E to 154°E
    if (lat >= -44 && lat <= -10 && lng >= 113 && lng <= 154) {
      return true;
    }
    // New Zealand: 34°S to 47°S, 166°E to 179°E
    if (lat >= -47 && lat <= -34 && lng >= 166 && lng <= 179) {
      return true;
    }
    // Pacific Islands: rough approximation
    if (lat >= -25 && lat <= 25 && lng >= 130 && lng <= 180) {
      return true;
    }
    // Eastern Pacific Islands (including Hawaii)
    if (lat >= -30 && lat <= 30 && lng >= -180 && lng <= -130) {
      return true;
    }
    return false;
  }

  /// Check if two continents are the same
  static bool isSameContinent(String continent1, String continent2) {
    return continent1.toLowerCase() == continent2.toLowerCase();
  }

  /// Get a user-friendly continent name
  static String getContinentDisplayName(String continent) {
    switch (continent.toLowerCase()) {
      case 'africa':
        return 'Africa';
      case 'antarctica':
        return 'Antarctica';
      case 'asia':
        return 'Asia';
      case 'europe':
        return 'Europe';
      case 'north america':
        return 'North America';
      case 'south america':
        return 'South America';
      case 'oceania':
        return 'Oceania';
      default:
        return 'Unknown';
    }
  }
}
