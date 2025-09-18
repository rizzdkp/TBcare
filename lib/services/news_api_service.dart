// lib/services/news_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article_model.dart';

class NewsApiService {
  static const String _baseUrl = 'https://newsdata.io/api/1/latest';
  static const String _apiKey =
      'pub_183299a48ea0429e8e50cf6d2b23fa18'; // Your actual API key

  static Future<List<NewsArticle>> fetchHealthNews() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?apikey=$_apiKey&q=tbc&language=id&size=10'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];

        // Filter out articles with null or empty required fields
        final validResults = results
            .where(
              (json) =>
                  json['title'] != null && json['title'].toString().isNotEmpty,
            )
            .toList();

        return validResults
            .map((json) => NewsArticle.fromNewsDataJson(json))
            .take(5) // Limit to 5 articles
            .toList();
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching news: $e');
      // Return dummy data if API fails
      return _getDummyTbcNews();
    }
  }

  static List<NewsArticle> _getDummyTbcNews() {
    return [
      NewsArticle(
        title: 'Pentingnya Deteksi Dini Tuberkulosis',
        description:
            'Deteksi dini TBC sangat penting untuk mencegah penyebaran dan meningkatkan kesembuhan pasien.',
        urlToImage: 'https://via.placeholder.com/150',
        url: '',
      ),
      NewsArticle(
        title: 'Gejala TBC Yang Harus Diwaspadai',
        description:
            'Batuk lebih dari 2 minggu, demam, dan penurunan berat badan bisa menjadi tanda TBC.',
        urlToImage: 'https://via.placeholder.com/150',
        url: '',
      ),
      NewsArticle(
        title: 'Cara Mencegah Penularan TBC',
        description:
            'Beberapa langkah pencegahan yang dapat dilakukan untuk menghindari penularan tuberkulosis.',
        urlToImage: 'https://via.placeholder.com/150',
        url: '',
      ),
    ];
  }

  // Alternative method for broader health news if TBC-specific news is limited
  static Future<List<NewsArticle>> fetchBroaderHealthNews() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl?apikey=$_apiKey&q=kesehatan,tuberculosis,paru&language=id&size=10',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];

        final validResults = results
            .where(
              (json) =>
                  json['title'] != null && json['title'].toString().isNotEmpty,
            )
            .toList();

        return validResults
            .map(
              (json) => NewsArticle.fromNewsDataJson(json),
            ) // Make sure this uses fromNewsDataJson
            .take(5)
            .toList();
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching broader health news: $e');
      return _getDummyTbcNews();
    }
  }
}
