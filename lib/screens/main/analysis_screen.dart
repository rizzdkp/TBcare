// lib/screens/main/analysis_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../features/anamnesis_form_screen.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  // Untuk simulasi, kita gunakan list sederhana. Nanti ini bisa diganti database.
  List<String> records = [];

  void _navigateAndAddRecord(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AnamnesisFormScreen()),
    );

    if (result == true) {
      setState(() {
        // Tambah data dummy ke list dan kirim notifikasi
        records.add("Record saved on ${DateTime.now()}");
        // TODO: Panggil service notifikasi di sini
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analysis',
          style: GoogleFonts.poppins(
            color: Color(0xFF00A8C5),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // This removes the back button
        actions: [
          // Tombol Tambah Data hanya muncul jika sudah ada data
          if (records.isNotEmpty)
            IconButton(
              icon: Icon(Icons.add_circle, color: Color(0xFFF39C12), size: 30),
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
          SizedBox(height: 20),
          Text('No Records Found',
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600])),
          SizedBox(height: 10),
          Text('Add your first health record to begin analysis.',
              style: GoogleFonts.poppins(color: Colors.grey[500])),
          SizedBox(height: 30),
          ElevatedButton.icon(
            icon: Icon(Icons.add, color: Colors.white),
            label: Text('Add New Record',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            onPressed: () => _navigateAndAddRecord(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1CB5E0),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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
      padding: EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(Icons.receipt_long, color: Color(0xFF00A8C5)),
            title: Text('Anamnesis Record #${index + 1}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            subtitle: Text(records[index]),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                setState(() {
                  records.removeAt(index);
                });
              },
            ),
          ),
        );
      },
    );
  }
}
