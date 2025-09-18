// lib/screens/main/home_screen.dart

import 'dart:async'; // Fixed: was 'dart.async'
import 'package:flutter/material.dart'; // Fixed: was 'package.flutter/material.dart'
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/news_article_model.dart';
import '../../services/news_api_service.dart';
import '../features/pemeriksaan_screen.dart';
import '../features/notifikasi_screen.dart';
import '../features/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); // Added const and key parameter

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _initialPage = 1000;
  final PageController _pageController = PageController(
    initialPage: _initialPage,
  );
  Timer? _timer;
  late Future<List<NewsArticle>> _newsFuture;
  int _currentPage = _initialPage;

  final List<Map<String, String>> _bannerData = [
    {
      'title': 'Batuk Lebih dari 2\nMinggu? Waspadai\nTBC!',
      'subtitle':
          'Lakukan Skrining Awal TBC Dengan Menganalisis\nSuara Batuk Anda Di Sini.',
      'buttonText': 'Cek Kondisi Anda',
    },
    {
      'title': 'Jaga Kesehatan\nParu-paru Anda.',
      'subtitle':
          'Ketahui cara menjaga paru-paru tetap sehat dan terhindar dari berbagai penyakit.',
      'buttonText': 'Lihat Tips Sehat',
    },
    {
      'title': 'Pentingnya\nDeteksi Dini TBC',
      'subtitle':
          'Semakin cepat terdeteksi, semakin besar peluang untuk sembuh total.',
      'buttonText': 'Pelajari Lebih Lanjut',
    },
  ];

  @override
  void initState() {
    super.initState();
    _newsFuture = NewsApiService.fetchHealthNews();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startBannerAutoScroll();
      }
    });
  }

  void _startBannerAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && mounted) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6F8),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),
            SizedBox(height: 16),
            _buildBannerSlider(),
            SizedBox(height: 24),
            _buildNewsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // --- PERUBAHAN DI SINI ---
              // Ikon pertama sekarang adalah Notifikasi
              _buildHeaderIcon(Icons.notifications_none_outlined, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NotifikasiScreen()),
                );
              }),
              SizedBox(width: 8),
              // Ikon kedua adalah Pengaturan (Settings)
              _buildHeaderIcon(Icons.settings_outlined, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsScreen()),
                );
              }),
            ],
          ),
          // --- Sisa kode tidak perlu diubah ---
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Hi, Welcome Back',
                    style: GoogleFonts.poppins(
                      color: Color(0xFF00BCD4),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Jane Doe',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12),
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?u=janedoe',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF39C12),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 4,
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        splashRadius: 20,
      ),
    );
  }

  Widget _buildBannerSlider() {
    return Container(
      height: 280,
      child: Stack(
        children: [
          // PageView with banners
          PageView.builder(
            controller: _pageController,
            itemCount: 10000,
            itemBuilder: (context, index) {
              final dataIndex = index % _bannerData.length;
              final item = _bannerData[dataIndex];

              VoidCallback onButtonPressed;
              if (dataIndex == 0) {
                onButtonPressed = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PemeriksaanScreen()),
                  );
                };
              } else if (dataIndex == 2) {
                onButtonPressed = () async {
                  const url =
                      'https://www.instagram.com/reel/DN7ZhjqERaw/?igsh=MXg3bndydXQ3ZjB0Zw==';

                  try {
                    final Uri uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      await launchUrl(uri, mode: LaunchMode.platformDefault);
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Tidak dapat membuka link: ${e.toString()}',
                        ),
                      ),
                    );
                  }
                };
              } else {
                onButtonPressed = () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tombol "${item['buttonText']}" ditekan!'),
                    ),
                  );
                };
              }

              return _buildBannerItem(
                title: item['title']!,
                subtitle: item['subtitle']!,
                buttonText: item['buttonText']!,
                onButtonPressed: onButtonPressed,
              );
            },
          ),
          // Fixed Left Arrow - Outside the PageView
          Positioned(
            left: 26, // Adjusted position
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: Color(0xFFF8A549),
                  size: 32,
                ),
                onPressed: () => _pageController.previousPage(
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                ),
                splashRadius: 25,
              ),
            ),
          ),
          // Fixed Right Arrow - Outside the PageView
          Positioned(
            right: 26, // Adjusted position
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: Color(0xFFF8A549),
                  size: 32,
                ),
                onPressed: () => _pageController.nextPage(
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                ),
                splashRadius: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerItem({
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1CB5E0), Color(0xFF00A8C5)],
          ),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.3), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              // Button at the bottom
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    elevation: 2,
                  ),
                  child: Text(
                    buttonText,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF39C12),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'News Today',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF39C12),
            ),
          ),
          SizedBox(height: 16),
          FutureBuilder<List<NewsArticle>>(
            future: _newsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return Center(child: Text('Gagal memuat berita.'));
              }
              final newsList = snapshot.data!.take(2).toList();
              return ListView.builder(
                itemCount: newsList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return _buildNewsCard(newsList[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(NewsArticle article) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF00A8C5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  article.description,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          if (article.urlToImage.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                article.urlToImage,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.white.withOpacity(0.1),
                  child: Icon(Icons.image_not_supported, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
