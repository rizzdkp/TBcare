// lib/services/news_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article_model.dart';

class NewsApiService {
  static const String _baseUrl = 'https://api.currentsapi.services/v1/search';
  static const String _apiKey =
      'y1mdq0K4w1P664KKcdLxb3clI8FXGxVDSjI-UtOkL67WlUL3';

  static Future<List<NewsArticle>> fetchHealthNews() async {
    try {
      // Coba beberapa pencarian yang berbeda untuk mendapatkan berita yang bervariasi
      List<NewsArticle> allArticles = [];

      // Pencarian 1: Tuberculosis umum
      final articles1 = await _fetchByKeyword('tuberculosis', 3);
      allArticles.addAll(articles1);

      // Pencarian 2: TB treatment
      final articles2 = await _fetchByKeyword('TB treatment', 2);
      allArticles.addAll(articles2);

      // Pencarian 3: TB vaccine
      final articles3 = await _fetchByKeyword('TB vaccine', 2);
      allArticles.addAll(articles3);

      // Remove duplicates berdasarkan title
      final uniqueArticles = <String, NewsArticle>{};
      for (var article in allArticles) {
        uniqueArticles[article.title] = article;
      }

      final result = uniqueArticles.values.toList();
      print('✅ Total unique articles found: ${result.length}');

      if (result.length >= 4) {
        return result.take(4).toList();
      } else {
        // Jika tidak cukup, tambahkan dummy data
        final remainingCount = 4 - result.length;
        final dummyNews = _getDummyTbcNews();
        result.addAll(dummyNews.take(remainingCount));
        return result;
      }
    } catch (e) {
      print('💥 Error fetching news: $e');
      return _getDummyTbcNews();
    }
  }

  static Future<List<NewsArticle>> _fetchByKeyword(
      String keyword, int limit) async {
    try {
      final uri = Uri.parse(
          '$_baseUrl?keywords=$keyword&apiKey=$_apiKey&page_size=$limit');

      print('🔍 Fetching news with keyword: $keyword');

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'PKM-App/1.0',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articles = data['news'] ?? [];

        final validArticles = articles
            .where((json) =>
                json['title'] != null &&
                json['title'].toString().isNotEmpty &&
                json['title'].toString() != '[Removed]' &&
                json['description'] != null &&
                json['description'].toString().isNotEmpty &&
                json['description'].toString() != '[Removed]')
            .toList();

        return validArticles
            .map((json) => NewsArticle.fromCurrentsJson(json))
            .toList();
      } else {
        print('❌ API Error for "$keyword": ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('💥 Error fetching "$keyword": $e');
      return [];
    }
  }

  static Future<List<NewsArticle>> fetchBroaderHealthNews() async {
    try {
      final uri = Uri.parse(
          '$_baseUrl?keywords=tuberculosis OR TB OR "lung disease" OR "respiratory infection"&apiKey=$_apiKey&page_size=8');

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'PKM-App/1.0',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articles = data['news'] ?? [];

        final validArticles = articles
            .where((json) =>
                json['title'] != null &&
                json['title'].toString().isNotEmpty &&
                json['title'].toString() != '[Removed]' &&
                json['description'] != null &&
                json['description'].toString().isNotEmpty &&
                json['description'].toString() != '[Removed]')
            .toList();

        // Remove duplicates dan ambil 4 artikel
        final uniqueArticles = <String, NewsArticle>{};
        for (var json in validArticles) {
          final article = NewsArticle.fromCurrentsJson(json);
          uniqueArticles[article.title] = article;
        }

        return uniqueArticles.values.take(4).toList();
      } else {
        return _getDummyTbcNews();
      }
    } catch (e) {
      print('💥 Error fetching broader health news: $e');
      return _getDummyTbcNews();
    }
  }

  static List<NewsArticle> _getDummyTbcNews() {
    print('📝 Returning 4 different dummy TBC news');
    return [
      NewsArticle(
        title: 'WHO Reports Global Tuberculosis Cases Reach 10.6 Million',
        description:
            'The World Health Organization\'s latest Global TB Report reveals that tuberculosis cases have increased to 10.6 million worldwide, with drug-resistant strains becoming a growing concern for public health officials.',
        urlToImage:
            'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=300&fit=crop',
        url: 'https://www.who.int/news-room/fact-sheets/detail/tuberculosis',
      ),
      NewsArticle(
        title: 'Breakthrough TB Vaccine Shows 75% Efficacy in Clinical Trials',
        description:
            'A new tuberculosis vaccine developed by researchers has demonstrated 75% efficacy in preventing active TB disease in clinical trials, marking the most promising advancement in TB prevention in decades.',
        urlToImage:
            'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=400&h=300&fit=crop',
        url: 'https://www.nature.com/articles/tb-vaccine-breakthrough-2024',
      ),
      NewsArticle(
        title: 'AI-Powered Chest X-Ray System Detects TB with 95% Accuracy',
        description:
            'Artificial intelligence technology is revolutionizing tuberculosis diagnosis in remote areas, with new chest X-ray analysis systems achieving 95% accuracy in detecting TB, significantly improving early detection rates.',
        urlToImage:
            'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?w=400&h=300&fit=crop',
        url:
            'https://www.thelancet.com/journals/lancet/article/ai-tb-diagnosis-2024',
      ),
      NewsArticle(
        title: 'New 4-Month TB Treatment Reduces Patient Burden Significantly',
        description:
            'Medical researchers have successfully developed a shortened 4-month tuberculosis treatment regimen that maintains high cure rates while reducing the treatment burden on patients and improving adherence.',
        urlToImage:
            'https://images.unsplash.com/photo-1582560475093-ba66accbc424?w=400&h=300&fit=crop',
        url:
            'https://www.cdc.gov/tb/publications/guideline-shortened-treatment',
      ),
    ];
  }
}
