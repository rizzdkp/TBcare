// lib/screens/main/home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/news_article_model.dart';
import '../../services/news_api_service.dart';
import '../../services/record_storage_service.dart';
import '../features/notifikasi_screen.dart';
import '../features/settings_screen.dart'; // Import SettingsScreen
import 'analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  // Menambahkan const dan key agar sesuai dengan praktik terbaik
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;
  int _notificationCount = 0; // Tambahkan ini
  late Future<List<NewsArticle>> _newsFuture;

  final List<Map<String, String>> _bannerData = [
    {
      'title': 'Batuk Lebih dari 2 Minggu? Waspadai TBC.',
      'subtitle':
          'Lakukan Skrining Awal TBC Dengan Menganalisis Suara Batuk Anda Di Sini.',
      'buttonText': 'Cek Kondisi Anda',
      'backgroundImage': 'assets/images/banner 1.jpg', 
    },
    {
      'title': 'Jaga Kesehatan Paru-paru Anda.',
      'subtitle':
          'Ketahui cara menjaga paru-paru tetap sehat dan terhindar dari berbagai penyakit.',
      'buttonText': 'Lihat Tips Sehat',
      'backgroundImage': 'assets/images/image.png', 
    },
    {
      'title': 'Pentingnya Deteksi Dini TBC',
      'subtitle':
          'Semakin cepat terdeteksi, semakin besar peluang untuk sembuh total.',
      'buttonText': 'Pelajari Lebih Lanjut',
      'backgroundImage':
          'assets/images/banner3.jpg', 
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 5000);
    _startAutoSlide();
    _newsFuture = NewsApiService.fetchHealthNews();
    
    // Initialize sample notifications
    RecordStorageService.addSampleNotifications();
    
    // Listen to notification changes
    RecordStorageService.addListener(_updateNotificationCount);
    _updateNotificationCount();
  }

  void _startAutoSlide() {
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
    RecordStorageService.removeListener(_updateNotificationCount);
    super.dispose();
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak bisa membuka link: $urlString')),
        );
      }
    }
  }

  // Update method _updateNotificationCount
  void _updateNotificationCount() {
    if (mounted) {
      final newCount = RecordStorageService.getAllNotifications()
          .where((notif) => !notif.isRead)
          .length;
      
      print('🔵 Updating notification count: $_notificationCount -> $newCount');
      
      setState(() {
        _notificationCount = newCount;
      });
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
              // Notification icon with badge
              Stack(
                children: [
                  _buildHeaderIcon(Icons.notifications_none, () async {
                    print('🔔 Opening notification screen');
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
                    );
                    // Refresh notification count when returning from notification screen
                    print('🔙 Returned from notification screen, updating count');
                    _updateNotificationCount();
                  }),
                  // Badge for notification count
                  if (_notificationCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '$_notificationCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              _buildHeaderIcon(Icons.settings, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              }),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Hi, WelcomeBack',
                    style: GoogleFonts.poppins(
                      color: const Color.fromARGB(255, 45, 167, 181),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Jane Doe',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?u=janedoe',
                    ),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.grey[700],
                      ),
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
      width: 36, // Reduced from default (around 48)
      height: 36, // Reduced from default (around 48)
      decoration: BoxDecoration(
        color: const Color(0xFFF39C12),
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
        icon: Icon(icon,
            color: Colors.white,
            size: 18), // Reduced icon size from default 24 to 18
        splashRadius: 18, // Reduced splash radius
        padding: EdgeInsets.zero, // Remove default padding
      ),
    );
  }

  Widget _buildBannerSlider() {
    return Container(
      height: 280, // Increased height to prevent overflow
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
                onButtonPressed = () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AnalysisScreen()),
                    );
              } else if (dataIndex == 2) {
                onButtonPressed = () => _launchURL(
                      'https://www.instagram.com/reel/DN7ZhjqERaw/?igsh=MXg3bndydXQ3ZjB0Zw==',
                    );
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
                backgroundImage: item['backgroundImage'], // Add this line
              );
            },
          ),
          // Fixed Left Arrow - Outside the PageView
          Positioned(
            left: 26,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: Color(0xFFF8A549), // Your requested color
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
            right: 26,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: Color(0xFFF8A549), // Your requested color
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
    String? backgroundImage,
  }) {
    // Debug log
    print('Loading banner image: $backgroundImage');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1CB5E0), Color(0xFF00A8C5)],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background image dengan better error handling
              if (backgroundImage != null)
                Positioned.fill(
                  child: Image.asset(
                    backgroundImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('❌ Error loading image: $backgroundImage');
                      print('❌ Error details: $error');
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1CB5E0), Color(0xFF00A8C5)],
                          ),
                        ),
                      );
                    },
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                      if (frame == null) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF1CB5E0), Color(0xFF00A8C5)],
                            ),
                          ),
                        );
                      }
                      print('✅ Image loaded successfully: $backgroundImage');
                      return Opacity(
                        opacity: 0.4, // Membuat gambar transparan
                        child: child,
                      );
                    },
                  ),
                ),
              // Overlay untuk kontras teks
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(32.0),
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            shadows: [
                              Shadow(
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.7),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 12,
                            height: 1.3,
                            shadows: [
                              Shadow(
                                offset: const Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black.withOpacity(0.7),
                              ),
                            ],
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
                          foregroundColor: const Color(0xFFF39C12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          buttonText,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFF39C12),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
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
              color: const Color.fromARGB(220, 255, 145, 0),
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<NewsArticle>>(
            future: _newsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
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
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
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
          const SizedBox(width: 12),
          if (article.urlToImage.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                article.urlToImage,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.white24,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
