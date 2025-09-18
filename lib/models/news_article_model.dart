// lib/models/news_article_model.dart

class NewsArticle {
  final String title;
  final String description;
  final String urlToImage;
  final String url;

  NewsArticle({
    required this.title,
    required this.description,
    required this.urlToImage,
    required this.url,
  });

  // For the newsdata.io API format
  factory NewsArticle.fromNewsDataJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? json['content'] ?? 'No Description',
      urlToImage: json['image_url'] ?? '', // newsdata.io uses 'image_url'
      url: json['link'] ?? '', // newsdata.io uses 'link'
    );
  }

  // Keep the old method for backward compatibility
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      urlToImage: json['urlToImage'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
