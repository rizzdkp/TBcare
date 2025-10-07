// lib/screens/main/warning_followup_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WarningFollowupScreen extends StatefulWidget {
  const WarningFollowupScreen({super.key});

  @override
  _WarningFollowupScreenState createState() => _WarningFollowupScreenState();
}

class _WarningFollowupScreenState extends State<WarningFollowupScreen> {
  // Data dummy untuk simulasi hasil analisis
  final List<FollowupItem> followupItems = [
    FollowupItem(
      id: '1',
      type: FollowupType.positive,
      title: 'Positif TBC - Segera Bertindak',
      description: 'Hasil analisis menunjukkan kemungkinan tinggi terkena TBC.',
      lastAnalysisDate: DateTime.now().subtract(const Duration(hours: 2)),
      priority: Priority.urgent,
      status: FollowupStatus.pending,
      actions: [
        'Segera kunjungi dokter spesialis paru',
        'Lakukan tes dahak untuk konfirmasi',
        'Mulai isolasi diri untuk mencegah penularan',
        'Hubungi faskes terdekat: RS Paru Jakarta (021-4891111)',
        'Edukasi keluarga tentang pencegahan TBC'
      ],
      warnings: [
        'PENTING: TBC adalah penyakit menular',
        'Gunakan masker saat berinteraksi dengan orang lain',
        'Jangan tunda pengobatan',
        'Catat semua gejala yang dialami'
      ],
    ),
    FollowupItem(
      id: '2',
      type: FollowupType.negative,
      title: 'Negatif TBC - Tetap Waspada',
      description: 'Hasil analisis tidak menunjukkan indikasi TBC.',
      lastAnalysisDate: DateTime.now().subtract(const Duration(days: 1)),
      priority: Priority.medium,
      status: FollowupStatus.monitoring,
      actions: [
        'Lanjutkan pemantauan gejala secara berkala',
        'Konsultasi dokter jika gejala memburuk',
        'Jaga pola hidup sehat dan kebersihan',
        'Tes ulang jika ada gejala baru',
        'Kontrol rutin setiap 3 bulan'
      ],
      warnings: [
        'Batuk bisa disebabkan kondisi lain',
        'Segera periksa jika gejala berlanjut > 2 minggu',
        'Waspadai demam tinggi dan batuk berdarah',
        'Jaga daya tahan tubuh dengan nutrisi baik'
      ],
    ),
    FollowupItem(
      id: '3',
      type: FollowupType.uncertain,
      title: 'Hasil Tidak Pasti - Perlu Pemeriksaan Lanjutan',
      description: 'Hasil analisis memerlukan konfirmasi lebih lanjut.',
      lastAnalysisDate: DateTime.now().subtract(const Duration(days: 3)),
      priority: Priority.high,
      status: FollowupStatus.pending,
      actions: [
        'Segera lakukan tes dahak BTA 3 kali',
        'Rontgen dada untuk evaluasi paru',
        'Konsultasi dokter spesialis paru',
        'Ulangi analisis suara batuk dalam 1 minggu',
        'Monitor suhu tubuh harian'
      ],
      warnings: [
        'Jangan abaikan gejala yang ada',
        'Hindari kontak dekat dengan lansia/anak-anak',
        'Segera ke IGD jika sesak napas berat',
        'Catat perubahan gejala setiap hari'
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.refresh, color: Color(0xFF00A8C5)),
            onPressed: () {
              setState(() {
                // Refresh data
              });
            },
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: followupItems.length,
      itemBuilder: (context, index) {
        final item = followupItems[index];
        return _buildFollowupCard(item);
      },
    );
  }

  Widget _buildFollowupCard(FollowupItem item) {
    Color typeColor;
    IconData typeIcon;
    Color priorityColor;

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
        typeIcon = Icons.help_outline;
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
          _buildContactItem('IGD RS Paru Jakarta', '021-4891111'),
          _buildContactItem('Puskesmas Terdekat', '119 (Halo Kemkes)'),
          _buildContactItem('Konsultasi Online', 'Telemedicine tersedia 24/7'),
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
