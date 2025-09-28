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

  // For Currents API format (primary method)
  factory NewsArticle.fromCurrentsJson(Map<String, dynamic> json) {
    // Pastikan image URL valid, jika tidak ada gunakan placeholder
    String imageUrl = json['image'] ?? '';

    // Jika image kosong atau null, gunakan placeholder yang berbeda untuk setiap artikel
    if (imageUrl.isEmpty) {
      final placeholders = [
        'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1582560475093-ba66accbc424?w=400&h=300&fit=crop',
      ];
      imageUrl = placeholders[DateTime.now().millisecond % placeholders.length];
    }

    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      urlToImage: imageUrl,
      url: json['url'] ?? '',
    );
  }

  // For NewsAPI format (backup method)
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['urlToImage'] ?? '';

    if (imageUrl.isEmpty) {
      final placeholders = [
        'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1582560475093-ba66accbc424?w=400&h=300&fit=crop',
      ];
      imageUrl = placeholders[DateTime.now().millisecond % placeholders.length];
    }

    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      urlToImage: imageUrl,
      url: json['url'] ?? '',
    );
  }
}
