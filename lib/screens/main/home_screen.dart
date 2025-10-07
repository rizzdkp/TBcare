// lib/screens/main/home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pkm/services/user_data_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/news_article_model.dart';
import '../../services/news_api_service.dart';
import '../../services/connectivity_service.dart';
import '../features/notifikasi_screen.dart';
import '../features/settings_screen.dart'; // Import SettingsScreen
import '../features/edit_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  // Menambahkan const dan key agar sesuai dengan praktik terbaik
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();

  // Update variabel news
  Future<List<NewsArticle>>? _newsFuture;

  // Add countdown variables
  Timer? _timer;
  Duration _timeUntil2030 = Duration.zero;
  int _notificationCount = 0; // Tambahkan ini

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
      'backgroundImage': 'assets/images/banner3.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _loadNews(); // load initial news
    _updateNotificationCount();
  }

  void _startCountdown() {
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final target = DateTime(2030, 1, 1); // 1 Januari 2030
    final difference = target.difference(now);

    if (mounted) {
      setState(() {
        _timeUntil2030 = difference;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // Update method _launchURL
  Future<void> _launchURL(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);

      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak bisa membuka link: $urlString'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error launching URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error membuka link: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Update method _updateNotificationCount
  void _updateNotificationCount() {
    if (mounted) {
      // Set dummy notification count since RecordStorageService is removed
      final newCount = 0;

      print('🔵 Updating notification count: $_notificationCount -> $newCount');

      setState(() {
        _notificationCount = newCount;
      });
    }
  }

  Future<void> _checkConnectivity() async {
    final hasConnection = await ConnectivityService.hasInternetConnection();
    final connectionType = await ConnectivityService.getConnectionType();

    if (!hasConnection) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection. Showing offline content.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      print('✅ Connected via: $connectionType');
    }
  }

  // Update method _loadNews untuk menggunakan parameter forceRefresh
  void _loadNews({bool forceRefresh = false}) {
    setState(() {
      _newsFuture = NewsApiService.fetchHealthNews(forceRefresh: forceRefresh);
    });
  }

  // Tambahkan method untuk refresh news
  void _refreshNews() {
    print('🔄 User triggered news refresh...');
    _loadNews(forceRefresh: true);

    // Show snackbar untuk feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.refresh, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Memperbarui berita...'),
          ],
        ),
        backgroundColor: Color(0xFF00A8C5),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Update _buildNewsSection untuk menambahkan tombol refresh
  Widget _buildNewsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF39C12), Color(0xFFE67E22)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.newspaper,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Berita TBC Terkini',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Tambahkan tombol refresh
                GestureDetector(
                  onTap: _refreshNews,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<NewsArticle>>(
            future: _newsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Memuat berita TBC terbaru...'),
                      ],
                    ),
                  ),
                );
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Gagal memuat berita TBC.',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Periksa koneksi internet atau coba lagi nanti.',
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _refreshNews,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final newsList = snapshot.data!;
              print('📰 Displaying ${newsList.length} news articles');

              return Column(
                children: [
                  // Show article count and refresh info
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${newsList.length} artikel ditemukan',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Ketuk ↻ untuk refresh',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // News list
                  ListView.builder(
                    itemCount: newsList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _buildNewsCard(newsList[index], index);
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Update _buildNewsCard untuk include index dan better layout
  Widget _buildNewsCard(NewsArticle article, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final url = article.url;
          if (url.isNotEmpty) {
            try {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tidak dapat membuka link berita'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with index badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    article.urlToImage,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 160,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 160,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Index badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.open_in_new,
                        size: 14,
                        color: Colors.blue[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Baca selengkapnya',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.blue[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCountdownSection(), // Replace banner with countdown
                  _buildTbcEliminationRoadmap(), // Add roadmap
                  _buildNewsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Replace banner section with countdown
  Widget _buildCountdownSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1CB5E0), Color(0xFF00A8C5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Countdown Eliminasi TBC',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Target Pencapaian Tahun 2030',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeUnit('Tahun', _timeUntil2030.inDays ~/ 365),
              _buildTimeUnit('Hari', _timeUntil2030.inDays % 365),
              _buildTimeUnit('Jam', _timeUntil2030.inHours % 24),
              _buildTimeUnit('Menit', _timeUntil2030.inMinutes % 60),
              _buildTimeUnit('Detik', _timeUntil2030.inSeconds % 60),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String label, int value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Add TBC Elimination Roadmap - Updated version
  Widget _buildTbcEliminationRoadmap() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Header Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  spreadRadius: 3,
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.timeline,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Peta Eliminasi TBC',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Strategi Nasional Indonesia',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Perjalanan menuju eliminasi TBC di Indonesia melalui 4 tahapan strategis dari tahun 2016 hingga 2030',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Roadmap Stages
          _buildEnhancedRoadmapStage(
            '2016',
            'Tahap 1',
            'Peluncuran Strategi TOSS-TBC',
            'Dilakukan:',
            [
              '1. Peluncuran Strategi TOSS-TBC, penemuan Intensif, Aktif, Masif, serta',
              '2. Kemitraan dan mobilisasi sosial dengan langkah-langkah:'
            ],
            [
              'Penguatan PPM (Public Private Mix – Kemitraan jajaran Pemerintah dan Swasta) dan penerapan',
              'Penemuan aktif',
              'Pemanfaatan TCM (Tes Cepat Molekuler) dan mikroskopis',
              'Desentralisasi kegiatan kepada Kabupaten/kota',
              'Penguatan regulasi dan kepemimpinan program',
              'Menerapkan exit strategy ketergantungan dari donor',
              'Penerapan kegiatan penurunan risiko penularan',
              'Penerapan shortterm regiment (pengobatan jangka pendek) untuk MDR-TB',
              'Akselerasi pengobatan kasus TBC mencapai 70% dan angka keberhasilan pengobatan diatas 85%'
            ],
            const Color(0xFF4CAF50),
            true,
            Icons.rocket_launch,
          ),

          _buildEnhancedRoadmapStage(
            '2020',
            'Tahap 2',
            'Pencapaian Target Antara',
            'Target: 30% penurunan insiden TBC & 40% penurunan kematian TBC (vs 2014)',
            ['Langkah-langkah strategis:'],
            [
              'Mempertahankan cakupan pengobatan tetap diatas 70% dan angka kesuksesan pengobatan diatas 85%',
              'Optimalisasi desentralisasi kegiatan TBC kepada Kabupaten/kota',
              'Mencegah pembiayaan katastropik TBC',
              'Penguatan pengendalian faktor risiko: profilaksis dan pengobatan TBC laten',
              'Maksimalisasi pemanfaatan diagnosis TCM dan mikroskopis',
              'Penerapan short term regiment (pengobatan jangka pendek) untuk TBC sensitif'
            ],
            const Color(0xFF2196F3),
            true,
            Icons.trending_up,
          ),

          _buildEnhancedRoadmapStage(
            '2025',
            'Tahap 3',
            'Akselerasi Menuju Eliminasi',
            'Target: 50% penurunan insiden TBC & 70% penurunan kematian TBC (vs 2014)',
            ['Langkah-langkah strategis:'],
            [
              'Mempertahankan cakupan pengobatan tetap diatas 80% dan angka kesuksesan pengobatan diatas 95%',
              'Menerapkan cakupan semesta untuk TBC',
              'Mengendalikan pembiayaan katastropik TBC',
              'Akselerasi pengobatan profilaksis dan pengobatan TBC laten',
              'Inovasi Pra-Skrining TBC - PKM-KC : TBcare',
              'Penguatan surveilans TBC',
              'Penerapan short term regiment (pengobatan jangka pendek) untuk laten TBC',
              'Penerapan vaksin TBC'
            ],
            const Color(0xFFFF9800),
            false,
            Icons.speed,
          ),

          _buildEnhancedRoadmapStage(
            '2030',
            'Tahap 4',
            'Eliminasi TBC',
            'Target: 90% penurunan insiden TBC & 95% penurunan kematian TBC (vs 2014)',
            [],
            [],
            const Color(0xFFE53935),
            false,
            Icons.celebration,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEnhancedRoadmapStage(
    String year,
    String stage,
    String subtitle,
    String description,
    List<String> mainPoints,
    List<String> bulletPoints,
    Color color,
    bool isCompleted,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: isCompleted ? color : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle : icon,
                      color: isCompleted ? Colors.white : color,
                      size: 24,
                    ),
                    Text(
                      year,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.white : color,
                      ),
                    ),
                  ],
                ),
              ),
              if (year != '2030')
                Container(
                  width: 4,
                  height: 50,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.8),
                        color.withOpacity(0.3),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),

          // Content card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.2), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stage header
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Text(
                      stage,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Description
                  if (description.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // Main points
                  if (mainPoints.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...mainPoints.map((point) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            point,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )),
                  ],

                  // Bullet points
                  if (bulletPoints.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: bulletPoints.map(
                          (point) {
                            final isInnovation = point.startsWith(
                                'Inovasi Pra-Skrining TBC - PKM-KC : TBcare');
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Titik biasa disembunyikan jika item inovasi (karena akan pakai styling khusus)
                                  if (!isInnovation)
                                    Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.only(
                                          top: 8, right: 12),
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  else
                                    const SizedBox(
                                        width: 18), // spasi agar rata teks
                                  Expanded(
                                    child: isInnovation
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  const Color(0xFF18B5B2)
                                                      .withOpacity(.15),
                                                  const Color(0xFF18B5B2)
                                                      .withOpacity(.05),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              border: Border.all(
                                                color: const Color(0xFF18B5B2)
                                                    .withOpacity(.55),
                                                width: 1.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF18B5B2)
                                                      .withOpacity(.15),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 26,
                                                  height: 26,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Color(0xFF18B5B2),
                                                        Color(0xFF0E8A86)
                                                      ],
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.auto_awesome,
                                                    size: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    point,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13.2,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                          0xFF0D5E5B),
                                                      height: 1.35,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Text(
                                            point,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: Colors.grey[700],
                                              height: 1.4,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ],

                  // Status indicator
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isCompleted
                            ? Colors.green.withOpacity(0.3)
                            : Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle : Icons.schedule,
                          size: 16,
                          color: isCompleted ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isCompleted
                              ? 'Telah Dilaksanakan'
                              : 'Target Masa Depan',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isCompleted ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE9F6FB),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(38),
          bottomRight: Radius.circular(38),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: topInset + 8,
          left: 20,
          right: 20,
          bottom: 18,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // KIRI: ikon notifikasi + settings
            Row(
              children: [
                _HeaderCircleButton(
                  icon: Icons.notifications_none_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => const NotifikasiScreen(),
                      ),
                    );
                  },
                  showDot: _notificationCount > 0,
                ),
                const SizedBox(width: 14),
                _HeaderCircleButton(
                  icon: Icons.settings_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const Spacer(),

            // TENGAH + KANAN: teks rata kanan & avatar
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Teks rata kanan
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Hi, WelcomeBack',
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight:
                            FontWeight.w500, // dibuat sedikit lebih tipis
                        color: const Color(0xFF18B5B2),
                        letterSpacing: .15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      UserDataService.fullName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w600, // sedikit lebih tipis dari w700
                        color: const Color(0xFF2D2F30),
                        letterSpacing: .1,
                        height: 1.05,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Avatar dapat ditekan -> EditProfile
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => const EditProfileScreen(),
                      ),
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF18B5B2),
                            width: 2,
                          ),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF18B5B2).withOpacity(.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/default_profile.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF18B5B2),
                              child:
                                  const Icon(Icons.person, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF18B5B2),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tombol bulat oranye untuk header
class _HeaderCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;
  const _HeaderCircleButton({
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: const Color(0xFFFFA020),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        if (showDot)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF0BC2D6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0BC2D6).withOpacity(.6),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
