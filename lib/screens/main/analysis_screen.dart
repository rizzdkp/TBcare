// lib/screens/main/analysis_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../features/anamnesis_form_screen.dart';
import '../../services/record_storage_service.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  List<AnamnesisRecord> records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
    RecordStorageService.addListener(_onRecordsChanged);
  }

  @override
  void dispose() {
    RecordStorageService.removeListener(_onRecordsChanged);
    super.dispose();
  }

  void _loadRecords() {
    setState(() {
      records = RecordStorageService.getAllRecords();
    });
  }

  void _onRecordsChanged() {
    _loadRecords();
  }

  void _navigateAndAddRecord(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnamnesisFormScreen()),
    );

    if (result is AnamnesisRecord) {
      RecordStorageService.addRecord(result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Record berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteRecord(String recordId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Hapus Record',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus record ini?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                RecordStorageService.deleteRecord(recordId);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Record berhasil dihapus!'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: Text(
                'Hapus',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analysis',
          style: GoogleFonts.poppins(
            color: const Color(0xFF00A8C5),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (records.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFFF39C12), size: 30),
              onPressed: () => _navigateAndAddRecord(context),
            )
        ],
      ),
      body: records.isEmpty ? _buildEmptyState() : _buildRecordList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text('No Records Found',
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600])),
          const SizedBox(height: 10),
          Text('Add your first health record to begin analysis.',
              style: GoogleFonts.poppins(color: Colors.grey[500])),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text('Add New Record',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            onPressed: () => _navigateAndAddRecord(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1CB5E0),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRecordList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.receipt_long, color: Color(0xFF00A8C5)),
            title: Text('Anamnesis Record #${records.length - index}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            subtitle: Text(
              'Dibuat: ${_formatDate(record.recordingDate)}',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteRecord(record.id),
            ),
            onTap: () {
              _showRecordDetails(record);
            },
          ),
        );
      },
    );
  }

  void _showRecordDetails(AnamnesisRecord record) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Detail Record',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: record.data.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${entry.key}:',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00A8C5),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.value,
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tutup', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
