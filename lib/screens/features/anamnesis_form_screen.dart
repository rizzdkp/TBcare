// lib/screens/features/anamnesis_form_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnamnesisFormScreen extends StatefulWidget {
  @override
  _AnamnesisFormScreenState createState() => _AnamnesisFormScreenState();
}

class _AnamnesisFormScreenState extends State<AnamnesisFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Helper untuk membuat input field
  Widget _buildTextField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF00A8C5))),
        SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a value';
            }
            return null;
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Record', style: GoogleFonts.poppins(color: Color(0xFF00A8C5), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF00A8C5)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('Sex (Male/Female)'),
              _buildTextField('Age'),
              _buildTextField('Height (cm)'),
              _buildTextField('Weight (Kg)'),
              _buildTextField('Cough Duration (<1wk, 1-2wks, etc.)'),
              _buildTextField('Productive Cough (Yes/No)'),
              _buildTextField('Hemoptysis (Yes/No)'),
              _buildTextField('Chest Pain (Yes/No)'),
              _buildTextField('Shortness of Breath (Yes/No)'),
              _buildTextField('Fever (Yes/No)'),
              _buildTextField('Night Sweats (Yes/No)'),
              _buildTextField('Weight Loss (Yes/No)'),
              _buildTextField('Tobacco Use (current/stopped/never)'),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Logic to save data will be here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Record Saved!')),
                      );
                      Navigator.pop(context, true); // Kirim sinyal bahwa data berhasil disimpan
                    }
                  },
                  child: Text('Save Record', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF39C12),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}