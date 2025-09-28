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

  // For NewsAPI format (primary method)
  factory NewsArticle.fromNewsApiJson(Map<String, dynamic> json) {
    String imageUrl = '';

    // NewsAPI menggunakan field 'urlToImage' untuk gambar
    if (json['urlToImage'] != null &&
        json['urlToImage'].toString().isNotEmpty &&
        json['urlToImage'] != 'null') {
      imageUrl = json['urlToImage'].toString();
    } else {
      // Fallback ke placeholder jika tidak ada gambar
      final placeholders = [
        'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1582560475093-ba66accbc424?w=400&h=300&fit=crop',
      ];
      imageUrl = placeholders[DateTime.now().millisecond % placeholders.length];
    }

    return NewsArticle(
      title: json['title']?.toString() ?? 'No Title Available',
      description: json['description']?.toString() ??
          json['content']?.toString() ??
          'No Description Available',
      urlToImage: imageUrl,
      url: json['url']?.toString() ?? '',
    );
  }

  // For Currents API format (backup method)
  factory NewsArticle.fromCurrentsJson(Map<String, dynamic> json) {
    String imageUrl = '';

    if (json['image'] != null && json['image'].toString().isNotEmpty) {
      imageUrl = json['image'].toString();
    } else {
      final placeholders = [
        'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1582560475093-ba66accbc424?w=400&h=300&fit=crop',
      ];
      imageUrl = placeholders[DateTime.now().millisecond % placeholders.length];
    }

    return NewsArticle(
      title: json['title']?.toString() ?? 'No Title Available',
      description:
          json['description']?.toString() ?? 'No Description Available',
      urlToImage: imageUrl,
      url: json['url']?.toString() ?? '',
    );
  }
}
