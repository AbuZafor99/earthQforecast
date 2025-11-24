import '../../../../core/utils/continent_utils.dart';

class EarthquakeModel {
  final String id;
  final double magnitude;
  final String place;
  final int time;
  final String url;
  final int tsunami;
  final String title;
  final double latitude;
  final double longitude;
  final double depth;
  final String continent;

  EarthquakeModel({
    required this.id,
    required this.magnitude,
    required this.place,
    required this.time,
    required this.url,
    required this.tsunami,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.depth,
    required this.continent,
  });

  factory EarthquakeModel.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'];
    final geometry = json['geometry'];
    final coordinates = geometry['coordinates'];

    final lat = (coordinates[1] as num?)?.toDouble() ?? 0.0;
    final lng = (coordinates[0] as num?)?.toDouble() ?? 0.0;

    return EarthquakeModel(
      id: json['id'] ?? '',
      magnitude: (properties['mag'] as num?)?.toDouble() ?? 0.0,
      place: properties['place'] ?? 'Unknown Location',
      time: properties['time'] ?? 0,
      url: properties['url'] ?? '',
      tsunami: properties['tsunami'] ?? 0,
      title: properties['title'] ?? '',
      longitude: lng,
      latitude: lat,
      depth: (coordinates[2] as num?)?.toDouble() ?? 0.0,
      continent: ContinentUtils.detectContinent(lat, lng),
    );
  }
}
