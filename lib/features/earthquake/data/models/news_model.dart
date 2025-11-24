class NewsModel {
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;
  final String sourceName;
  final String category; // 'news' or 'forecast'
  final String country; // Country code or name

  NewsModel({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.sourceName,
    this.category = 'news',
    this.country = 'global',
  });

  factory NewsModel.fromNewsApi(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No description available',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? DateTime.now().toIso8601String(),
      sourceName: json['source']?['name'] ?? 'Unknown Source',
      category: 'news',
      country: 'global',
    );
  }

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      sourceName: json['source']?['name'] ?? 'Unknown Source',
    );
  }
}
