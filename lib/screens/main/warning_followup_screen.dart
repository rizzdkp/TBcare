// lib/screens/main/warning_followup_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/user_data_service.dart';
import '../../services/api_service.dart';

class WarningFollowupScreen extends StatefulWidget {
  const WarningFollowupScreen({super.key});

  @override
  _WarningFollowupScreenState createState() => _WarningFollowupScreenState();
}

class _WarningFollowupScreenState extends State<WarningFollowupScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    UserDataService.addListener(_onDataChanged);
    _loadDataFromAPI();
  }

  @override
  void dispose() {
    UserDataService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    print('🔔 WARNING SCREEN - Data changed! Triggering rebuild...');
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadDataFromAPI() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      print('🌐 WARNING SCREEN - Fetching data from API...');
      final response = await ApiService.getPatientHistory();

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        // Simpan patient data (including tbcareProfile)
        if (data['patient'] != null) {
          UserDataService.syncFromAPI(data['patient']);
          print('✅ WARNING - Patient synced (with tbcareProfile)');
        }

        // NEW: Use first history item as "firstExam"
        if (data['history'] != null &&
            data['history'] is List &&
            (data['history'] as List).isNotEmpty) {
          final firstHistoryItem = (data['history'] as List)[0];
          UserDataService.setFirstExamData(firstHistoryItem);
          UserDataService.setHistoryData(data['history']);
          print('✅ WARNING - First history item saved as firstExam');
          print('   ID: ${firstHistoryItem['_id']}');
          print('   Result: ${firstHistoryItem['result']}');
          print('   History synced: ${(data['history'] as List).length} items');
        } else {
          UserDataService.setFirstExamData(null);
          UserDataService.setHistoryData([]);
          print('⚠️ WARNING - No history in API');
        }
      } else {
        print('❌ WARNING - API call failed: ${response['message']}');
      }
    } catch (e) {
      print('❌ WARNING - Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Generate followup items dari API data (menggunakan history array)
  List<FollowupItem> get followupItems {
    final firstExam = UserDataService.getFirstExamData();
    final historyData = UserDataService.getHistoryData();

    print('⚠️ WARNING SCREEN - Generating followup items...');
    print(
        '⚠️ WARNING SCREEN - firstExam: ${firstExam != null ? "EXISTS" : "NULL"}');
    if (firstExam != null) {
      print('⚠️ WARNING SCREEN - firstExam._id: ${firstExam['_id']}');
      print('⚠️ WARNING SCREEN - firstExam.result: ${firstExam['result']}');
      print('⚠️ WARNING SCREEN - firstExam full data: $firstExam');
    }
    print('⚠️ WARNING SCREEN - history count: ${historyData.length}');

    // Jika belum ada analisis sama sekali, tidak ada yang perlu ditampilkan
    if (firstExam == null) {
      print('⚠️ WARNING SCREEN - firstExam is NULL, return EMPTY');
      return [];
    }

    if (historyData.isEmpty) {
      print(
          'ℹ️ WARNING SCREEN - History kosong tapi firstExam ada, menggunakan firstExam untuk follow up');
    }

    String resultType =
        firstExam['result']?.toString().toUpperCase() ?? 'UNKNOWN';
    DateTime analysisDate = DateTime.now();

    if (firstExam['createdAt'] != null) {
      try {
        analysisDate = DateTime.parse(firstExam['createdAt'].toString());
      } catch (e) {
        print('Error parsing date: $e');
      }
    }

    String sputum =
        firstExam['sputumCondition']?.toString() ?? 'Tidak diketahui';

    // Extract segment counts and other info from history item
    int tbSegmentCount = firstExam['tbSegmentCount'] ?? 0;
    int totalCoughSegments = firstExam['totalCoughSegments'] ?? 0;

    print(
        '⚠️ WARNING SCREEN - Ada analisis, result: $resultType, sputum: $sputum, TB segments: $tbSegmentCount/$totalCoughSegments');

    final isPositive = resultType == 'TB' ||
        resultType.contains('POSITIVE') ||
        resultType.contains('DANGER');
    final isNegative = resultType == 'NORMAL' ||
        resultType == 'SAFE' ||
        resultType == 'NEGATIVE' ||
        resultType.contains('SAFE');

    if (isPositive) {
      // TB POSITIF
      print(
          '⚠️ WARNING SCREEN - Menampilkan peringatan TB POSITIF (URGENT, status COMPLETED, pending hilang)');
      return [
        FollowupItem(
          id: firstExam['_id']?.toString() ??
              firstExam['id']?.toString() ??
              '1',
          type: FollowupType.positive,
          title: 'Positif TBC - Segera Bertindak',
          description:
              'Hasil analisis menunjukkan kemungkinan tinggi terkena TBC. Kondisi sputum: $sputum. Segmen TB terdeteksi: $tbSegmentCount dari $totalCoughSegments segmen batuk.',
          lastAnalysisDate: analysisDate,
          priority: Priority.urgent,
          status: FollowupStatus.completed,
          actions: [
            'Segera kunjungi dokter spesialis paru',
            'Lakukan tes dahak (BTA) 3 kali untuk konfirmasi',
            'Mulai isolasi diri untuk mencegah penularan',
            'Hubungi faskes terdekat: RS Paru Surabaya (031-5501078)',
            'Edukasi keluarga tentang pencegahan TBC',
            'Lakukan rontgen thorax untuk melihat kondisi paru'
          ],
          warnings: [
            'PENTING: TBC adalah penyakit menular melalui udara',
            'Gunakan masker saat berinteraksi dengan orang lain',
            'Jangan tunda pengobatan - TBC dapat disembuhkan dengan obat',
            'Catat semua gejala yang dialami (batuk, demam, keringat malam)',
            'Hindari kontak dekat dengan bayi, anak-anak, dan lansia',
            'Konsumsi makanan bergizi untuk meningkatkan daya tahan tubuh'
          ],
        ),
      ];
    } else if (isNegative) {
      // NORMAL/NEGATIF
      print(
          '⚠️ WARNING SCREEN - Menampilkan peringatan NEGATIF (status MONITORING, pending hilang)');
      return [
        FollowupItem(
          id: firstExam['_id']?.toString() ??
              firstExam['id']?.toString() ??
              '1',
          type: FollowupType.negative,
          title: 'Negatif TBC - Tetap Waspada',
          description:
              'Hasil analisis tidak menunjukkan indikasi TBC. Kondisi sputum: $sputum. Segmen non-TB: ${firstExam['nonTbSegmentCount'] ?? 0} dari $totalCoughSegments segmen batuk.',
          lastAnalysisDate: analysisDate,
          priority: Priority.medium,
          status: FollowupStatus.monitoring,
          actions: [
            'Lanjutkan pemantauan gejala secara berkala',
            'Konsultasi dokter jika batuk berlanjut > 2 minggu',
            'Jaga pola hidup sehat dan kebersihan lingkungan',
            'Tes ulang jika muncul gejala baru (demam, keringat malam)',
            'Kontrol rutin setiap 3 bulan jika ada riwayat kontak TB',
            'Tingkatkan daya tahan tubuh dengan olahraga dan nutrisi'
          ],
          warnings: [
            'Batuk bisa disebabkan oleh kondisi lain (infeksi virus, alergi)',
            'Segera periksa jika gejala memburuk atau muncul batuk berdarah',
            'Waspadai demam tinggi yang tidak turun > 3 hari',
            'Jaga ventilasi rumah agar udara selalu segar',
            'Hindari asap rokok dan polusi udara',
            'Istirahat cukup dan kelola stress dengan baik'
          ],
        ),
      ];
    } else {
      print(
          '⚠️ WARNING SCREEN - Menampilkan peringatan hasil tidak pasti/lanjutan');
      return [
        FollowupItem(
          id: firstExam['_id']?.toString() ??
              firstExam['id']?.toString() ??
              '1',
          type: FollowupType.uncertain,
          title: 'Perlu Pemeriksaan Lanjutan',
          description:
              'Hasil analisis belum konklusif. Kondisi sputum: $sputum. Total segmen batuk: $totalCoughSegments.',
          lastAnalysisDate: analysisDate,
          priority: Priority.high,
          status: FollowupStatus.inProgress,
          actions: [
            'Jadwalkan pemeriksaan lanjutan di fasilitas kesehatan',
            'Diskusikan dengan dokter untuk tes tambahan (rontgen, kultur dahak)',
            'Catat gejala yang dialami setiap hari',
            'Hindari kontak dekat dengan keluarga sampai hasil final',
            'Lakukan pola hidup bersih dan sehat sambil menunggu hasil akhir'
          ],
          warnings: [
            'Hasil ini belum final, jangan panik namun tetap waspada',
            'Jaga penggunaan masker untuk mencegah kemungkinan penularan',
            'Segera konsultasi jika muncul gejala tambahan seperti demam tinggi',
            'Ikuti arahan tenaga kesehatan selama proses pemeriksaan lanjutan'
          ],
        ),
      ];
    }
  }

  // FollowupItem(
  //   id: '2',
  //   type: FollowupType.negative,
  //   title: 'Negatif TBC - Tetap Waspada',
  //   description: 'Hasil analisis tidak menunjukkan indikasi TBC.',
  //   lastAnalysisDate: DateTime.now().subtract(const Duration(days: 1)),
  //   priority: Priority.medium,
  //   status: FollowupStatus.monitoring,
  //   actions: [
  //     'Lanjutkan pemantauan gejala secara berkala',
  //     'Konsultasi dokter jika gejala memburuk',
  //     'Jaga pola hidup sehat dan kebersihan',
  //     'Tes ulang jika ada gejala baru',
  //     'Kontrol rutin setiap 3 bulan'
  //   ],
  //   warnings: [
  //     'Batuk bisa disebabkan kondisi lain',
  //     'Segera periksa jika gejala berlanjut > 2 minggu',
  //     'Waspadai demam tinggi dan batuk berdarah',
  //     'Jaga daya tahan tubuh dengan nutrisi baik'
  //   ],
  // ),
  // FollowupItem(
  //   id: '3',
  //   type: FollowupType.uncertain,
  //   title: 'Hasil Tidak Pasti - Perlu Pemeriksaan Lanjutan',
  @override
  Widget build(BuildContext context) {
    print('🎨 WARNING SCREEN - BUILD called');
    print('   followupItems.length: ${followupItems.length}');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(
          'Peringatan & Tindak Lanjut',
          style: GoogleFonts.poppins(
            color: const Color(0xFF00A8C5),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF00A8C5)),
                    ),
                  )
                : const Icon(Icons.refresh, color: Color(0xFF00A8C5)),
            onPressed: _isLoading ? null : _loadDataFromAPI,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCards(),
          Expanded(
            child: _buildFollowupList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final urgentCount =
        followupItems.where((item) => item.priority == Priority.urgent).length;
    final pendingCount = followupItems
        .where((item) => item.status == FollowupStatus.pending)
        .length;

    print('📊 WARNING - Summary Cards:');
    print('   Urgent: $urgentCount');
    print('   Pending: $pendingCount');
    print('   Total: ${followupItems.length}');

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Urgent',
              urgentCount.toString(),
              Colors.red,
              Icons.priority_high,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Pending',
              pendingCount.toString(),
              Colors.orange,
              Icons.pending_actions,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Total',
              followupItems.length.toString(),
              Colors.blue,
              Icons.list_alt,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowupList() {
    print('📋 WARNING - Building list with ${followupItems.length} items');

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (followupItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_information_outlined,
                size: 120,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 24),
              Text(
                'Data Belum Dianalisis',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hasil batuk anda sedang dianalisis',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _loadDataFromAPI,
                icon: const Icon(Icons.refresh),
                label: Text(
                  'Muat Ulang Data',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A8C5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: followupItems.length,
      itemBuilder: (context, index) {
        final item = followupItems[index];
        print('   Item $index: ${item.title} - Status: ${item.status}');
        return _buildFollowupCard(item);
      },
    );
  }

  Widget _buildFollowupCard(FollowupItem item) {
    Color typeColor;
    IconData typeIcon;
    Color priorityColor;

    // Jika item id adalah pending, gunakan icon khusus
    final isPendingItem = item.id == 'pending_1';

    switch (item.type) {
      case FollowupType.positive:
        typeColor = Colors.red;
        typeIcon = Icons.dangerous;
        break;
      case FollowupType.negative:
        typeColor = Colors.green;
        typeIcon = Icons.check_circle;
        break;
      case FollowupType.uncertain:
        typeColor = Colors.orange;
        // Gunakan icon berbeda untuk pending vs uncertain lainnya
        typeIcon = isPendingItem ? Icons.pending_actions : Icons.help_outline;
        break;
    }

    switch (item.priority) {
      case Priority.urgent:
        priorityColor = Colors.red;
        break;
      case Priority.high:
        priorityColor = Colors.orange;
        break;
      case Priority.medium:
        priorityColor = Colors.blue;
        break;
      case Priority.low:
        priorityColor = Colors.green;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            width: 4,
            color: priorityColor,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(20),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            typeIcon,
            color: typeColor,
            size: 24,
          ),
        ),
        title: Text(
          item.title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              item.description,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.priority.name.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: priorityColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.timeAgo,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          _buildActionSection(
              '🚨 PERINGATAN PENTING', item.warnings, Colors.red),
          const SizedBox(height: 16),
          _buildActionSection(
              '📋 TINDAK LANJUT YANG DIPERLUKAN', item.actions, Colors.blue),
          const SizedBox(height: 16),
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildActionSection(String title, List<String> items, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          ...items
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📞 KONTAK DARURAT',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 12),
          _buildContactItem('IGD RS Paru Surabaya', '021-4891111'),
          _buildContactItem('Puskesmas Terdekat', '119 (Halo Kemkes)'),
        ],
      ),
    );
  }

  Widget _buildContactItem(String title, String contact) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.phone, color: Colors.green[600], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title: $contact',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Model classes for the followup system
enum FollowupType { positive, negative, uncertain }

enum Priority { urgent, high, medium, low }

enum FollowupStatus { pending, inProgress, completed, monitoring }

class FollowupItem {
  final String id;
  final FollowupType type;
  final String title;
  final String description;
  final DateTime lastAnalysisDate;
  final Priority priority;
  final FollowupStatus status;
  final List<String> actions;
  final List<String> warnings;

  FollowupItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.lastAnalysisDate,
    required this.priority,
    required this.status,
    required this.actions,
    required this.warnings,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(lastAnalysisDate);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
}
