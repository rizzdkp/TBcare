// lib/screens/main/histori_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/history_record_model.dart';
import '../../services/history_service.dart';
import '../features/history_detail_screen.dart';

class HistoriScreen extends StatefulWidget {
  const HistoriScreen({super.key});

  @override
  _HistoriScreenState createState() => _HistoriScreenState();
}

class _HistoriScreenState extends State<HistoriScreen> {
  List<HistoryRecord> records = [];
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    HistoryService.initializeDummyData();
    _loadRecords();
    HistoryService.addListener(_onRecordsChanged);
  }

  @override
  void dispose() {
    HistoryService.removeListener(_onRecordsChanged);
    super.dispose();
  }

  void _loadRecords() {
    setState(() {
      records = HistoryService.getAllRecords();
    });
  }

  void _onRecordsChanged() {
    _loadRecords();
  }

  List<HistoryRecord> get filteredRecords {
    if (selectedFilter == 'All') return records;

    AnalysisResult? filterResult;
    switch (selectedFilter) {
      case 'Safe':
        filterResult = AnalysisResult.safe;
        break;
      case 'Warning':
        filterResult = AnalysisResult.warning;
        break;
      case 'Danger':
        filterResult = AnalysisResult.danger;
        break;
    }

    return records.where((record) => record.result == filterResult).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(
          'History Analysis',
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
            child: filteredRecords.isEmpty
                ? _buildEmptyState()
                : _buildRecordsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Safe', 'Warning', 'Danger'];

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
    final safeCount =
        records.where((r) => r.result == AnalysisResult.safe).length;
    final warningCount =
        records.where((r) => r.result == AnalysisResult.warning).length;
    final dangerCount =
        records.where((r) => r.result == AnalysisResult.danger).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem('Aman', safeCount, const Color(0xFF4CAF50)),
          const SizedBox(width: 1, height: 40, child: VerticalDivider()),
          _buildStatItem('Waspada', warningCount, const Color(0xFFFF9800)),
          const SizedBox(width: 1, height: 40, child: VerticalDivider()),
          _buildStatItem('Bahaya', dangerCount, const Color(0xFFE53935)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$count',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada riwayat analisis',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Riwayat analisis akan muncul setelah Anda\nmelakukan pemeriksaan suara batuk',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) {
        final record = filteredRecords[index];
        return _buildHistoryCard(record);
      },
    );
  }

  Widget _buildHistoryCard(HistoryRecord record) {
    Color primaryColor;
    Color backgroundColor;
    IconData iconData;

    switch (record.result) {
      case AnalysisResult.safe:
        primaryColor = const Color(0xFF4CAF50);
        backgroundColor = const Color(0xFF4CAF50);
        iconData = Icons.check_circle;
        break;
      case AnalysisResult.warning:
        primaryColor = const Color(0xFFFF9800);
        backgroundColor = const Color(0xFFFF9800);
        iconData = Icons.warning;
        break;
      case AnalysisResult.danger:
        primaryColor = const Color(0xFFE53935);
        backgroundColor = const Color(0xFFE53935);
        iconData = Icons.dangerous;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoryDetailScreen(record: record),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  backgroundColor,
                  backgroundColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(iconData, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.resultTitle,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'ID: ${record.anamnesisId}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            record.confidencePercentage,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            record.timeAgo,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    record.resultDescription,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.graphic_eq,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Tap untuk lihat spektogram',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.white, size: 14),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Hasil',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildFilterOption('Semua', 'All', Icons.list),
              _buildFilterOption(
                  'Aman', 'Safe', Icons.check_circle, Colors.green),
              _buildFilterOption(
                  'Waspada', 'Warning', Icons.warning, Colors.orange),
              _buildFilterOption(
                  'Bahaya', 'Danger', Icons.dangerous, Colors.red),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String title, String value, IconData icon,
      [Color? color]) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
      selected: selectedFilter == value,
      onTap: () {
        setState(() {
          selectedFilter = value;
        });
        Navigator.pop(context);
      },
    );
  }
}
