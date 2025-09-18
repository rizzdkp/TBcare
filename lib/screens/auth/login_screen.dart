import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main/main_screen.dart'; // <-- Path import diperbaiki

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Hello!',
          style: GoogleFonts.poppins(
            color: Color(0xFF00A8C5),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF00A8C5)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF39C12),
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Email or Mobile Number',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Color(0xFF00A8C5),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            TextFormField(decoration: _inputDecoration('example@example.com')),
            SizedBox(height: 20),
            Text(
              'Password',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Color(0xFF00A8C5),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              obscureText: !_isPasswordVisible,
              decoration: _inputDecoration('**********').copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
            ),
            SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigasi ke MainScreen setelah login berhasil
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => MainScreen(),
                    ), // <-- Navigasi diperbaiki
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1CB5E0),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Log In',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
