import 'package:dio/dio.dart';
import '../models/earthquake_model.dart';
import '../models/news_model.dart';

class ApiService {
  final Dio _dio = Dio();
  static const String _baseUrl =
      'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary';

  // Fetch earthquakes from the last 24 hours
  Future<List<EarthquakeModel>> getRecentEarthquakes() async {
    try {
      final response = await _dio.get('$_baseUrl/all_day.geojson');

      if (response.statusCode == 200) {
        final data = response.data;
        final List features = data['features'];
        return features.map((e) => EarthquakeModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load recent earthquakes');
      }
    } catch (e) {
      throw Exception('Error fetching recent earthquakes: $e');
    }
  }

  // Fetch significant earthquakes from the last 30 days
  Future<List<EarthquakeModel>> getSignificantEarthquakes() async {
    try {
      final response = await _dio.get('$_baseUrl/significant_month.geojson');

      if (response.statusCode == 200) {
        final data = response.data;
        final List features = data['features'];
        return features.map((e) => EarthquakeModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load significant earthquakes');
      }
    } catch (e) {
      throw Exception('Error fetching significant earthquakes: $e');
    }
  }

  // Mock News Data (Keep as is for now)
  Future<List<NewsModel>> getEarthquakeNews() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      NewsModel(
        title: "Major Earthquake Preparedness: What You Need to Know",
        description:
            "Experts advise on the best ways to prepare your home and family for seismic events. Learn about emergency kits, evacuation plans, and home safety checks.",
        url: "https://www.ready.gov/earthquakes",
        urlToImage:
            "https://images.unsplash.com/photo-1583324113626-70df0f4deaab?q=80&w=1000&auto=format&fit=crop",
        publishedAt: DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        sourceName: "Emergency Prep",
      ),
      NewsModel(
        title: "Recent Seismic Activity in the Pacific Ring of Fire",
        description:
            "Geologists report increased activity in the Pacific region. Stay updated with the latest data on tectonic movements and potential risks.",
        url: "https://www.usgs.gov/programs/earthquake-hazards/earthquakes",
        urlToImage:
            "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=1000&auto=format&fit=crop",
        publishedAt: DateTime.now()
            .subtract(const Duration(hours: 5))
            .toIso8601String(),
        sourceName: "USGS News",
      ),
      NewsModel(
        title: "Understanding Magnitude vs. Intensity",
        description:
            "Learn the difference between earthquake magnitude and intensity and why it matters for assessing damage and risk.",
        url:
            "https://www.usgs.gov/natural-hazards/earthquake-hazards/science/magnitude-vs-intensity",
        urlToImage:
            "https://images.unsplash.com/photo-1517816743773-6e0fd518b4a6?q=80&w=1000&auto=format&fit=crop",
        publishedAt: DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
        sourceName: "Science Daily",
      ),
      NewsModel(
        title: "New Earthquake Early Warning System Launched",
        description:
            "A new app promises to give seconds of warning before shaking starts. This technology could save thousands of lives in future events.",
        url: "https://www.shakealert.org/",
        urlToImage:
            "https://images.unsplash.com/photo-1580974618801-bc5f638b4f96?q=80&w=1000&auto=format&fit=crop",
        publishedAt: DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
        sourceName: "Tech Crunch",
      ),
      NewsModel(
        title: "Global Seismic Monitor: Weekly Report",
        description:
            "A summary of significant seismic events from around the globe this week. Analysis of trends and patterns.",
        url: "https://ds.iris.edu/seismon/",
        urlToImage:
            "https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=1000&auto=format&fit=crop",
        publishedAt: DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String(),
        sourceName: "IRIS",
      ),
      NewsModel(
        title: "Building Resilient Cities: Earthquake Engineering",
        description:
            "How modern engineering is making cities safer against earthquakes. Innovations in base isolation and damping systems.",
        url: "https://www.eeri.org/",
        urlToImage:
            "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=1000&auto=format&fit=crop",
        publishedAt: DateTime.now()
            .subtract(const Duration(days: 4))
            .toIso8601String(),
        sourceName: "EERI",
      ),
    ];
  }
}
