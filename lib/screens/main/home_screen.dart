// lib/screens/main/home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/news_article_model.dart';
import '../../services/news_api_service.dart';
import '../features/notifikasi_screen.dart';
import 'analysis_screen.dart'; // <-- Import halaman analisis

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _initialPage = 1000;
  final PageController _pageController = PageController(initialPage: _initialPage);
  Timer? _timer;
  late Future<List<NewsArticle>> _newsFuture;

  final List<Map<String, String>> _bannerData = [
    {
      'title': 'Batuk Lebih dari 2 Minggu? Waspadai TBC.',
      'subtitle': 'Lakukan Skrining Awal TBC Dengan Menganalisis Suara Batuk Anda Di Sini.',
      'buttonText': 'Cek Kondisi Anda',
    },
    {
      'title': 'Jaga Kesehatan Paru-paru Anda.',
      'subtitle': 'Ketahui cara menjaga paru-paru tetap sehat dan terhindar dari berbagai penyakit.',
      'buttonText': 'Lihat Tips Sehat',
    },
    {
      'title': 'Pentingnya Deteksi Dini TBC',
      'subtitle': 'Semakin cepat terdeteksi, semakin besar peluang untuk sembuh total.',
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
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
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

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak bisa membuka link: $urlString')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildBannerSlider(),
            const SizedBox(height: 24),
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
              _buildHeaderIcon(Icons.notifications_none_outlined, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => NotifikasiScreen()));
              }),
              const SizedBox(width: 8),
              _buildHeaderIcon(Icons.settings_outlined, () {}),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Hi, WelcomeBack', style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12)),
                  Text('Jane Doe', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                ],
              ),
              const SizedBox(width: 12),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=janedoe')),
                  Positioned(
                    bottom: -4, right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(Icons.edit, size: 16, color: Colors.grey[700]),
                    ),
                  ),
                ],
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
        color: const Color(0xFFF39C12),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), spreadRadius: 2, blurRadius: 4)],
      ),
      child: IconButton(onPressed: onPressed, icon: Icon(icon, color: Colors.white), splashRadius: 20),
    );
  }


  Widget _buildBannerSlider() {
    return SizedBox(
      height: 210,
      child: PageView.builder(
        controller: _pageController,
        itemCount: 10000,
        itemBuilder: (context, index) {
          final dataIndex = index % _bannerData.length;
          final item = _bannerData[dataIndex];

          VoidCallback onButtonPressed;
          // PERUBAHAN UTAMA: Arahkan tombol banner pertama ke AnalysisScreen
          if (dataIndex == 0) {
            onButtonPressed = () => Navigator.push(context, MaterialPageRoute(builder: (_) => AnalysisScreen()));
          } else if (dataIndex == 2) {
            onButtonPressed = () => _launchURL('https://www.instagram.com/reel/DN7ZhjqERaw/?igsh=MXg3bndydXQ3ZjB0Zw==');
          } else {
            onButtonPressed = () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tombol "${item['buttonText']}" ditekan!')),
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
    );
  }

  Widget _buildBannerItem({
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                'https://img.freepik.com/free-vector/virus-transmission-concept-illustration_114360-1663.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  title,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2, shadows: [const Shadow(blurRadius: 10, color: Colors.black54)]),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 14, shadows: [const Shadow(blurRadius: 8, color: Colors.black45)]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    buttonText,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF39C12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: Colors.white.withOpacity(0.7)),
              onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.7)),
              onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('News Today', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          FutureBuilder<List<NewsArticle>>(
            future: _newsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Gagal memuat berita.'));
              }
              final newsList = snapshot.data!.take(2).toList();
              return ListView.builder(
                itemCount: newsList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1CB5E0), Color(0xFF00A8C5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.cyan.withOpacity(0.2), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(article.description, style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 12), maxLines: 3, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (article.urlToImage.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                article.urlToImage,
                width: 90, height: 90, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(width: 90, height: 90, color: Colors.white24, child: const Icon(Icons.image_not_supported, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}