// lib/screens/features/anamnesis_form_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/record_storage_service.dart';

class AnamnesisFormScreen extends StatefulWidget {
  const AnamnesisFormScreen({super.key});

  @override
  _AnamnesisFormScreenState createState() => _AnamnesisFormScreenState();
}

class _AnamnesisFormScreenState extends State<AnamnesisFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  final List<String> _fields = [
    'Sex (Male/Female)',
    'Age',
    'Height (cm)',
    'Weight (Kg)',
    'Cough Duration (<1wk, 1-2wks, etc.)',
    'Productive Cough (Yes/No)',
    'Hemoptysis (Yes/No)',
    'Chest Pain (Yes/No)',
    'Shortness of Breath (Yes/No)',
    'Fever (Yes/No)',
    'Night Sweats (Yes/No)',
    'Weight Loss (Yes/No)',
    'Tobacco Use (current/stopped/never)',
  ];

  @override
  void initState() {
    super.initState();
    for (String field in _fields) {
      _controllers[field] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Helper untuk membuat input field
  Widget _buildTextField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF00A8C5))),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controllers[label],
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a value';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Record',
            style: GoogleFonts.poppins(
                color: const Color(0xFF00A8C5), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF00A8C5)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ..._fields.map((field) => _buildTextField(field)),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Create record
                      final recordData = <String, String>{};
                      _controllers.forEach((key, controller) {
                        recordData[key] = controller.text;
                      });

                      final record = AnamnesisRecord(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        recordingDate: DateTime.now(),
                        data: recordData,
                      );

                      Navigator.pop(context, record);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF39C12),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text('Save Record',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
