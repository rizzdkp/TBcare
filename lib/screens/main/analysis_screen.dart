// lib/screens/main/analysis_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/history_record_model.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  List<HistoryRecord> analysisResults = [];
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadDummyAnalysisResults();
  }

  void _loadDummyAnalysisResults() {
    // Data dummy hasil analisis dari API web
    setState(() {
      analysisResults = [
        HistoryRecord(
          id: '1',
          anamnesisId: 'anamnesis_1',
          analysisDate: DateTime.now().subtract(const Duration(hours: 2)),
          result: AnalysisResult.danger,
          resultTitle: 'Positif TBC',
          resultDescription:
              'Hasil analisis menunjukkan kemungkinan tinggi terkena TBC berdasarkan suara batuk yang dianalisis.',
          recommendation:
              'Segera lakukan pemeriksaan lanjutan dan konsultasi dengan dokter.',
          audioPath: '/audio/sample1.wav',
          spectrogramPath: '/images/spectrogram1.png',
          confidence: 0.87,
          analysisData: {
            'frequency_analysis': 'Abnormal',
            'pattern_recognition': 'TBC Pattern Detected',
            'ml_prediction': 'Positive'
          },
        ),
        HistoryRecord(
          id: '2',
          anamnesisId: 'anamnesis_2',
          analysisDate: DateTime.now().subtract(const Duration(days: 1)),
          result: AnalysisResult.safe,
          resultTitle: 'Negatif TBC',
          resultDescription:
              'Hasil analisis menunjukkan tidak ada indikasi TBC berdasarkan suara batuk.',
          recommendation: 'Tetap pantau gejala dan lakukan pemeriksaan rutin.',
          audioPath: '/audio/sample2.wav',
          spectrogramPath: '/images/spectrogram2.png',
          confidence: 0.92,
          analysisData: {
            'frequency_analysis': 'Normal',
            'pattern_recognition': 'Healthy Pattern',
            'ml_prediction': 'Negative'
          },
        ),
        HistoryRecord(
          id: '3',
          anamnesisId: 'anamnesis_3',
          analysisDate: DateTime.now().subtract(const Duration(days: 3)),
          result: AnalysisResult.warning,
          resultTitle: 'Perlu Pemeriksaan Lanjutan',
          resultDescription:
              'Hasil analisis menunjukkan pola yang memerlukan pemeriksaan lebih lanjut.',
          recommendation:
              'Disarankan untuk melakukan tes dahak dan konsultasi dokter.',
          audioPath: '/audio/sample3.wav',
          spectrogramPath: '/images/spectrogram3.png',
          confidence: 0.75,
          analysisData: {
            'frequency_analysis': 'Borderline',
            'pattern_recognition': 'Inconclusive',
            'ml_prediction': 'Uncertain'
          },
        ),
      ];
    });
  }

  List<HistoryRecord> get filteredResults {
    if (selectedFilter == 'All') return analysisResults;

    AnalysisResult? filterResult;
    switch (selectedFilter) {
      case 'Positif':
        filterResult = AnalysisResult.danger;
        break;
      case 'Negatif':
        filterResult = AnalysisResult.safe;
        break;
      case 'Perlu Pemeriksaan':
        filterResult = AnalysisResult.warning;
        break;
    }

    return analysisResults
        .where((result) => result.result == filterResult)
        .toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Filter Hasil Analisis',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('All', style: GoogleFonts.poppins()),
                onTap: () {
                  setState(() {
                    selectedFilter = 'All';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Positif TBC', style: GoogleFonts.poppins()),
                onTap: () {
                  setState(() {
                    selectedFilter = 'Positif';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Negatif TBC', style: GoogleFonts.poppins()),
                onTap: () {
                  setState(() {
                    selectedFilter = 'Negatif';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Perlu Pemeriksaan', style: GoogleFonts.poppins()),
                onTap: () {
                  setState(() {
                    selectedFilter = 'Perlu Pemeriksaan';
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(
          'Hasil Analisis TBC',
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
            icon: const Icon(Icons.filter_list, color: Color(0xFF00A8C5)),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          _buildStatistics(),
          Expanded(
            child: filteredResults.isEmpty
                ? _buildEmptyState()
                : _buildAnalysisResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Positif', 'Negatif', 'Perlu Pemeriksaan'];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                filter,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : const Color(0xFF00A8C5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedFilter = filter;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF00A8C5),
              checkmarkColor: Colors.white,
              side: const BorderSide(color: Color(0xFF00A8C5)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatistics() {
    final positifCount =
        analysisResults.where((r) => r.result == AnalysisResult.danger).length;
    final negatifCount =
        analysisResults.where((r) => r.result == AnalysisResult.safe).length;
    final pemeriksaanCount =
        analysisResults.where((r) => r.result == AnalysisResult.warning).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Positif TBC', positifCount, Colors.red),
          _buildStatCard('Negatif TBC', negatifCount, Colors.green),
          _buildStatCard('Perlu Pemeriksaan', pemeriksaanCount, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAnalysisResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredResults.length,
      itemBuilder: (context, index) {
        final result = filteredResults[index];
        return _buildAnalysisCard(result);
      },
    );
  }

  Widget _buildAnalysisCard(HistoryRecord result) {
    Color resultColor;
    IconData resultIcon;

    switch (result.result) {
      case AnalysisResult.danger:
        resultColor = Colors.red;
        resultIcon = Icons.dangerous;
        break;
      case AnalysisResult.safe:
        resultColor = Colors.green;
        resultIcon = Icons.check_circle;
        break;
      case AnalysisResult.warning:
        resultColor = Colors.orange;
        resultIcon = Icons.warning;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: resultColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    resultIcon,
                    color: resultColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.resultTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.timeAgo,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: resultColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    result.confidencePercentage,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: resultColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              result.resultDescription,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.recommend,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.recommendation,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text('Belum Ada Hasil Analisis',
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600])),
          const SizedBox(height: 10),
          Text(
              'Data hasil analisis akan muncul di sini setelah proses analisis selesai.',
              style: GoogleFonts.poppins(color: Colors.grey[500])),
        ],
      ),
    );
  }
}
