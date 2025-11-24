import 'package:dio/dio.dart';
import '../models/earthquake_model.dart';
import '../models/news_model.dart';

class ApiService {
  final Dio _dio = Dio();
  static const String _baseUrl =
      'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary';

  // News API configuration
  static const String _newsApiKey =
      'YOUR_NEWS_API_KEY_HERE'; // User needs to replace this
  static const String _newsApiUrl = 'https://newsapi.org/v2/everything';

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

  // Fetch real earthquake news from News API
  Future<List<NewsModel>> getEarthquakeNews({String? country}) async {
    try {
      // If API key is not set, return mock data
      if (_newsApiKey == 'YOUR_NEWS_API_KEY_HERE') {
        return _getMockNews(country: country);
      }

      final queryParams = {
        'q': 'earthquake OR seismic OR tremor',
        'sortBy': 'publishedAt',
        'language': 'en',
        'apiKey': _newsApiKey,
        'pageSize': 20,
      };

      if (country != null && country != 'global') {
        queryParams['q'] = 'earthquake $country';
      }

      final response = await _dio.get(
        _newsApiUrl,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List articles = data['articles'] ?? [];
        return articles
            .map((article) => NewsModel.fromNewsApi(article))
            .toList();
      } else {
        return _getMockNews(country: country);
      }
    } catch (e) {
      print('Error fetching news: $e');
      return _getMockNews(country: country);
    }
  }

  // Fetch forecast/prediction news
  Future<List<NewsModel>> getForecastNews({String? country}) async {
    // Since real earthquake prediction APIs are rare, using curated mock data
    await Future.delayed(const Duration(milliseconds: 500));

    final allForecasts = [
      NewsModel(
        title:
            "Seismologists Warn of Increased Activity in Pacific Ring of Fire",
        description:
            "Recent seismic data suggests heightened tectonic activity in the Pacific region. Experts recommend preparedness measures for coastal communities.",
        url: "https://www.usgs.gov/programs/earthquake-hazards",
        urlToImage:
            "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=1000&auto=format&fit=crop",
        publishedAt: DateTime.now()
            .subtract(const Duration(hours: 3))
            .toIso8601String(),
        sourceName: "USGS Forecast",
        category: 'forecast',
        country: 'global',
      ),
      NewsModel(
        title: "California Earthquake Probability Increases for 2025",
        description:
            "New models predict a 75% chance of a magnitude 6.0+ earthquake in California within the next year. Residents urged to review emergency plans.",
        url: "https://www.earthquakeauthority.com/",
        urlToImage:
            "https://images.unsplash.com/photo-1517816743773-6e0fd518b4a6?q=80&w=1000&auto=format&fit=crop",
        publishedAt: DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
        sourceName: "California Earthquake Authority",
        category: 'forecast',
        country: 'USA',
      ),
      NewsModel(
        title: "Japan Issues Long-term Earthquake Forecast for Tokyo Region",
        description:
            "Japanese meteorological agency releases 30-year forecast indicating 70% probability of major earthquake affecting Tokyo metropolitan area.",
        url: "https://www.jma.go.jp/",
        urlToImage:
            "https://images.unsplash.com/photo-1542051841857-5f90071e7989?q=80&w=1000&auto=format&fit=crop",
        publishedAt: DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
        sourceName: "Japan Meteorological Agency",
        category: 'forecast',
        country: 'Japan',
      ),
      NewsModel(
        title: "Turkey Earthquake Risk Assessment Updated",
        description:
            "New geological surveys reveal increased seismic risk along the North Anatolian Fault. Infrastructure reinforcement programs accelerated.",
        url: "https://www.afad.gov.tr/",
        urlToImage:
            "https://images.unsplash.com/photo-1541888946425-d81bb19240f5?q=80&w=1000&auto=format&fit=crop",
        publishedAt: DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String(),
        sourceName: "AFAD Turkey",
        category: 'forecast',
        country: 'Turkey',
      ),
      NewsModel(
        title: "Indonesia Tsunami Warning System Upgraded",
        description:
            "Following recent seismic activity patterns, Indonesia enhances early warning capabilities for coastal regions prone to earthquake-induced tsunamis.",
        url: "https://www.bmkg.go.id/",
        urlToImage:
            "https://images.unsplash.com/photo-1559827260-dc66d52bef19?q=80&w=1000&auto=format&fit=crop",
        publishedAt: DateTime.now()
            .subtract(const Duration(days: 4))
            .toIso8601String(),
        sourceName: "BMKG Indonesia",
        category: 'forecast',
        country: 'Indonesia',
      ),
    ];

    if (country != null && country != 'global') {
      return allForecasts
          .where((f) => f.country.toLowerCase().contains(country.toLowerCase()))
          .toList();
    }

    return allForecasts;
  }

  // Mock news data fallback
  List<NewsModel> _getMockNews({String? country}) {
    final allNews = [
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
        category: 'news',
        country: 'USA',
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
        category: 'news',
        country: 'global',
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
        category: 'news',
        country: 'global',
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
        category: 'news',
        country: 'USA',
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
        category: 'news',
        country: 'global',
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
        category: 'news',
        country: 'global',
      ),
    ];

    if (country != null && country != 'global') {
      return allNews
          .where((n) => n.country.toLowerCase().contains(country.toLowerCase()))
          .toList();
    }

    return allNews;
  }
}
