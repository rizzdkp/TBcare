// lib/services/news_api_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/news_article_model.dart';

class NewsApiService {
  static const String _baseUrl = 'https://newsapi.org/v2/everything';
  static const String _apiKey = '5638d41547ee44a2a4f016d603e6fd84';

  // Add cache untuk track artikel yang sudah pernah ditampilkan
  static Set<String> _shownArticleTitles = <String>{};
  static final List<String> _sortOptions = ['publishedAt', 'popularity', 'relevancy'];
  static int _currentSortIndex = 0;

  static Future<List<NewsArticle>> fetchHealthNews(
      {bool forceRefresh = false}) async {
    print('🚀 Starting to fetch TBC news (Indonesia first, then global)...');

    // Reset cache jika force refresh
    if (forceRefresh) {
      _shownArticleTitles.clear();
      print('🔄 Cache cleared for fresh articles');
    }

    try {
      List<NewsArticle> allArticles = [];

      // FASE 1: Cari berita TBC Indonesia terlebih dahulu
      print('🇮🇩 FASE 1: Searching for TBC news in Indonesia...');

      // Pencarian Indonesia dengan variasi keyword dan sort
      final indonesiaKeywords = [
        'TBC Indonesia',
        'tuberculosis Indonesia',
        'TB Indonesia',
        'tuberkulosis Indonesia', // tambah variasi
        '"TBC" Indonesia',
        'kesehatan paru Indonesia'
      ];

      for (int i = 0;
          i < indonesiaKeywords.length && allArticles.length < 4;
          i++) {
        final keyword = indonesiaKeywords[i];
        print('🔍 Indonesia search $i: $keyword');
        final articles =
            await _fetchByKeywordWithVariation(keyword, 3, forceRefresh);
        print('📰 Found ${articles.length} articles for $keyword');
        allArticles.addAll(articles);
      }

      // Remove duplicates dari hasil Indonesia
      final uniqueIndonesiaArticles = _filterUniqueArticles(allArticles);
      print(
          '✅ Total unique Indonesia articles found: ${uniqueIndonesiaArticles.values.length}');

      // Jika sudah cukup artikel Indonesia, return
      if (uniqueIndonesiaArticles.length >= 4) {
        final result = uniqueIndonesiaArticles.values.take(4).toList();
        _updateShownArticles(result);
        print('🎉 Returning ${result.length} Indonesia articles');
        return result;
      }

      // FASE 2: Jika artikel Indonesia kurang, tambahkan berita global
      if (uniqueIndonesiaArticles.isNotEmpty &&
          uniqueIndonesiaArticles.length < 4) {
        print('🌍 FASE 2: Adding global TBC news to complete the list...');
        final remainingCount = 4 - uniqueIndonesiaArticles.length;
        print('📊 Need $remainingCount more articles from global sources');

        final globalArticles =
            await _fetchGlobalTbcNews(remainingCount + 3, forceRefresh);

        // Gabungkan Indonesia + Global, hindari duplikat
        final allUniqueArticles = <String, NewsArticle>{};
        allUniqueArticles.addAll(uniqueIndonesiaArticles);

        for (var article in globalArticles) {
          if (!allUniqueArticles.containsKey(article.title) &&
              !_shownArticleTitles.contains(article.title)) {
            allUniqueArticles[article.title] = article;
          }
        }

        final finalResult = allUniqueArticles.values.take(4).toList();
        _updateShownArticles(finalResult);
        print(
            '🎉 Returning ${finalResult.length} mixed articles (Indonesia + Global)');
        return finalResult;
      }

      // FASE 3: Jika tidak ada artikel Indonesia sama sekali, cari global
      print(
          '🌍 FASE 3: No Indonesia articles found, searching global TBC news...');
      final globalArticles = await _fetchGlobalTbcNews(
          6, forceRefresh); // ambil lebih banyak untuk variasi

      if (globalArticles.isNotEmpty) {
        final finalGlobal = globalArticles.take(4).toList();
        _updateShownArticles(finalGlobal);
        print('🎉 Returning ${finalGlobal.length} global articles');
        return finalGlobal;
      }

      // FASE 4: Fallback ke alternative search
      print('❌ No TBC articles found, trying alternative search...');
      return await _fetchAlternativeNews(forceRefresh);
    } catch (e) {
      print('💥 Error in fetchHealthNews: $e');
      return _getDummyTbcNews();
    }
  }

  static Future<List<NewsArticle>> _fetchGlobalTbcNews(
      int limit, bool forceRefresh) async {
    print('🌍 Fetching global TBC news...');
    List<NewsArticle> globalArticles = [];

    // Variasi keyword global dengan lebih banyak opsi
    final globalKeywords = [
      'tuberculosis',
      'TB disease',
      'tuberculosis treatment',
      'TB vaccine',
      'tuberculosis diagnosis',
      'TB prevention',
      'lung tuberculosis',
      'tuberculosis WHO'
    ];

    // Gunakan keyword yang berbeda setiap kali
    final random = Random();
    final shuffledKeywords = List<String>.from(globalKeywords)..shuffle(random);

    for (int i = 0;
        i < shuffledKeywords.length && globalArticles.length < limit;
        i++) {
      final keyword = shuffledKeywords[i];
      print('🔍 Global search $i: $keyword');
      final articles =
          await _fetchByKeywordWithVariation(keyword, 3, forceRefresh);
      print('📰 Found ${articles.length} global articles for $keyword');
      globalArticles.addAll(articles);
    }

    final uniqueGlobalArticles = _filterUniqueArticles(globalArticles);
    print('✅ Total unique global articles: ${uniqueGlobalArticles.length}');
    return uniqueGlobalArticles.values.toList();
  }

  static Future<List<NewsArticle>> _fetchByKeywordWithVariation(
      String keyword, int limit, bool forceRefresh) async {
    try {
      final encodedKeyword = Uri.encodeComponent(keyword);

      // Rotate sort option untuk variasi hasil
      final currentSort = _sortOptions[_currentSortIndex % _sortOptions.length];
      _currentSortIndex++;

      // Tambah parameter untuk variasi
      final random = Random();
      final page = forceRefresh ? random.nextInt(3) + 1 : 1; // random page 1-3
      final pageSize = limit + random.nextInt(5); // variasi page size

      // Format URL untuk NewsAPI dengan variasi
      final uri = Uri.parse(
          '$_baseUrl?q=$encodedKeyword&apiKey=$_apiKey&pageSize=$pageSize&page=$page&sortBy=$currentSort&language=en');

      print('📡 NewsAPI Call (sort: $currentSort, page: $page): $uri');

      final response = await http.get(
        uri,
        headers: {
          'User-Agent':
              'PKM-TBC-App/${random.nextInt(100)}.0', // vary user agent
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📊 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📋 API Status: ${data['status']}');
        print('📋 Total Results: ${data['totalResults']}');

        if (data['status'] == 'ok') {
          final List<dynamic> articles = data['articles'] ?? [];
          print('📰 Raw articles count: ${articles.length}');

          if (articles.isNotEmpty) {
            print('📰 Sample title: ${articles[0]['title']}');
          }

          final validArticles = articles.where((json) {
            final title = json['title']?.toString() ?? '';
            final description = json['description']?.toString() ?? '';

            // Filter artikel yang benar-benar terkait TBC
            return title.isNotEmpty &&
                !title.contains('[Removed]') &&
                !title.toLowerCase().contains('null') &&
                description.isNotEmpty &&
                !description.contains('[Removed]') &&
                !description.toLowerCase().contains('null') &&
                !_shownArticleTitles.contains(title) &&
                _isTbcRelated(title, description); // Tambah filter TBC
          }).toList();

          print(
              '✅ Valid TBC-related articles for "$keyword": ${validArticles.length}');

          return validArticles
              .map((json) {
                try {
                  return NewsArticle.fromNewsApiJson(json);
                } catch (e) {
                  print('⚠️ Error parsing article: $e');
                  return null;
                }
              })
              .where((article) => article != null)
              .cast<NewsArticle>()
              .take(limit)
              .toList();
        } else {
          print('❌ API returned error status: ${data['status']}');
          print('❌ API message: ${data['message'] ?? 'No message'}');
          return [];
        }
      } else {
        print('❌ HTTP Error ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('💥 Exception in _fetchByKeywordWithVariation "$keyword": $e');
      return [];
    }
  }

  // Tambah method untuk filter artikel yang benar-benar terkait TBC
  static bool _isTbcRelated(String title, String description) {
    final titleLower = title.toLowerCase();
    final descLower = description.toLowerCase();
    final content = '$titleLower $descLower';

    // Keyword TBC yang harus ada
    final tbcKeywords = [
      'tbc',
      'tuberculosis',
      'tuberkulosis',
      'tb ',
      ' tb',
      'tb disease',
      'mycobacterium',
      'paru-paru',
      'lung infection'
    ];

    // Cek apakah ada keyword TBC
    final hasTbcKeyword =
        tbcKeywords.any((keyword) => content.contains(keyword));

    if (!hasTbcKeyword) {
      print(
          '❌ Filtered out (no TBC keyword): ${title.substring(0, title.length > 50 ? 50 : title.length)}...');
      return false;
    }

    // Keyword yang harus dihindari (tidak terkait TBC)
    final excludeKeywords = [
      'covid',
      'coronavirus',
      'flu',
      'influenza',
      'diabetes',
      'cancer',
      'kanker',
      'heart disease',
      'stroke',
      'hypertension',
      'malaria',
      'dengue',
      'zika',
      'hepatitis',
      'hiv',
      'aids',
      'pneumonia',
      'asthma',
      'bronchitis',
      'fashion',
      'sports',
      'entertainment',
      'politics',
      'ekonomi',
      'bisnis',
      'technology',
      'gadget',
      'smartphone',
      'bitcoin',
      'crypto'
    ];

    // Cek apakah ada keyword yang harus dihindari
    final hasExcludeKeyword =
        excludeKeywords.any((keyword) => content.contains(keyword));

    if (hasExcludeKeyword) {
      print(
          '❌ Filtered out (exclude keyword): ${title.substring(0, title.length > 50 ? 50 : title.length)}...');
      return false;
    }

    print(
        '✅ TBC-related article: ${title.substring(0, title.length > 50 ? 50 : title.length)}...');
    return true;
  }

  static Map<String, NewsArticle> _filterUniqueArticles(
      List<NewsArticle> articles) {
    final uniqueArticles = <String, NewsArticle>{};
    for (var article in articles) {
      if (article.title.isNotEmpty &&
          !article.title.contains('[Removed]') &&
          !_shownArticleTitles.contains(article.title) &&
          _isTbcRelated(article.title, article.description)) {
        // Tambah filter TBC di sini juga
        uniqueArticles[article.title] = article;
      }
    }
    return uniqueArticles;
  }

  static void _updateShownArticles(List<NewsArticle> articles) {
    for (var article in articles) {
      _shownArticleTitles.add(article.title);
    }
    // Batasi cache agar tidak terlalu besar
    if (_shownArticleTitles.length > 50) {
      final list = _shownArticleTitles.toList();
      _shownArticleTitles = list.skip(25).toSet(); // keep only latest 25
    }
    print(
        '📝 Updated shown articles cache: ${_shownArticleTitles.length} titles');
  }

  // Method untuk reset cache manual
  static void resetCache() {
    _shownArticleTitles.clear();
    _currentSortIndex = 0;
    print('🔄 Cache and sort index reset');
  }

  static Future<List<NewsArticle>> _fetchAlternativeNews(
      bool forceRefresh) async {
    print('🔄 Trying alternative TBC search with different approach...');

    try {
      // Gunakan keyword TBC yang lebih spesifik untuk alternative search
      final tbcKeywords = [
        'tuberculosis treatment',
        'TB diagnosis',
        'tuberculosis vaccine',
        'TBC Indonesia',
        'tuberculosis WHO'
      ];
      final random = Random();
      final keyword = tbcKeywords[random.nextInt(tbcKeywords.length)];

      final uri = Uri.parse(
          '$_baseUrl?q=$keyword&apiKey=$_apiKey&pageSize=10&sortBy=publishedAt&language=en');

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'PKM-TBC-App/1.0',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'ok') {
          final List<dynamic> articles = data['articles'] ?? [];

          final validArticles = articles.where((json) {
            final title = json['title']?.toString() ?? '';
            final description = json['description']?.toString() ?? '';

            return title.isNotEmpty &&
                !title.contains('[Removed]') &&
                description.isNotEmpty &&
                !description.contains('[Removed]') &&
                !_shownArticleTitles.contains(title) &&
                _isTbcRelated(title,
                    description); // Filter TBC untuk alternative search juga
          }).toList();

          print(
              '✅ Alternative TBC search found: ${validArticles.length} articles');

          if (validArticles.isNotEmpty) {
            return validArticles
                .take(4)
                .map((json) {
                  try {
                    return NewsArticle.fromNewsApiJson(json);
                  } catch (e) {
                    print('⚠️ Error parsing alternative article: $e');
                    return null;
                  }
                })
                .where((article) => article != null)
                .cast<NewsArticle>()
                .toList();
          }
        }
      }

      print('⚠️ Alternative search failed, returning dummy TBC data');
      return _getDummyTbcNews();
    } catch (e) {
      print('💥 Alternative search error: $e');
      return _getDummyTbcNews();
    }
  }

  static List<NewsArticle> _getDummyTbcNews() {
    print('📝 Returning dummy TBC news as fallback');
    final random = Random();
    final dummyArticles = [
      NewsArticle(
        title: 'Kemenkes RI Luncurkan Program Eliminasi TBC 2030',
        description:
            'Kementerian Kesehatan Indonesia meluncurkan program nasional eliminasi tuberkulosis dengan target mengurangi 90% kasus TBC pada tahun 2030.',
        urlToImage:
            'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=300&fit=crop',
        url: 'https://www.kemkes.go.id/article/view/program-eliminasi-tbc-2030',
      ),
      NewsArticle(
        title: 'Breakthrough TB Vaccine Shows 75% Efficacy in Clinical Trials',
        description:
            'A new tuberculosis vaccine developed by researchers has demonstrated 75% efficacy in preventing active TB disease in clinical trials.',
        urlToImage:
            'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=400&h=300&fit=crop',
        url: 'https://www.nature.com/articles/tb-vaccine-breakthrough',
      ),
      NewsArticle(
        title: 'AI-Powered Chest X-Ray System Detects TB with 95% Accuracy',
        description:
            'Artificial intelligence technology is revolutionizing tuberculosis diagnosis with new chest X-ray analysis systems achieving 95% accuracy.',
        urlToImage:
            'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?w=400&h=300&fit=crop',
        url:
            'https://www.thelancet.com/journals/lancet/article/ai-tb-diagnosis',
      ),
      NewsArticle(
        title: 'WHO Indonesia Dukung Penguatan Sistem Surveilans TBC',
        description:
            'World Health Organization Indonesia mendukung penguatan sistem surveilans tuberkulosis di Indonesia melalui program pelatihan petugas kesehatan.',
        urlToImage:
            'https://images.unsplash.com/photo-1582560475093-ba66accbc424?w=400&h=300&fit=crop',
        url:
            'https://www.who.int/indonesia/news/detail/surveilans-tbc-indonesia',
      ),
      NewsArticle(
        title: 'Puskesmas Tingkatkan Layanan Tes Cepat TBC di Indonesia',
        description:
            'Program pemerintah untuk meningkatkan akses tes cepat TBC di puskesmas seluruh Indonesia menunjukkan hasil positif dalam deteksi dini.',
        urlToImage:
            'https://images.unsplash.com/photo-1559757288-72ee7d4d0944?w=400&h=300&fit=crop',
        url: 'https://www.kemkes.go.id/article/view/tes-cepat-tbc-puskesmas',
      ),
      NewsArticle(
        title: 'Terobosan Pengobatan TBC Resistan Obat di Indonesia',
        description:
            'Penelitian terbaru menunjukkan efektivitas pengobatan baru untuk TBC resistan obat dengan tingkat kesembuhan mencapai 80%.',
        urlToImage:
            'https://images.unsplash.com/photo-1582560475179-6b61e6c87dff?w=400&h=300&fit=crop',
        url: 'https://www.litbang.kemkes.go.id/pengobatan-tbc-resistan',
      ),
    ];

    // Shuffle dan ambil 4 artikel random
    dummyArticles.shuffle(random);
    return dummyArticles.take(4).toList();
  }
}
