import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main/main_screen.dart';
import '../../services/api_service.dart';
import '../../services/user_data_service.dart';
import '../../services/notification_service.dart';
import '../features/notifikasi_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Validate input
    if (_emailController.text.trim().isEmpty) {
      _showError('Email tidak boleh kosong');
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showError('Password tidak boleh kosong');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (response['success'] == true) {
          print('✅ Login berhasil, loading user data...');

          // Tampilkan notifikasi welcome
          final userName = UserDataService.fullName;
          await NotifikasiScreen.addNotification(
            title: '👋 Selamat Datang!',
            message:
                'Halo $userName, selamat datang kembali di TBcare. Semoga hari Anda menyenangkan!',
            type: NotificationType.welcome,
          );

          // Load data user dari API setelah login
          await _loadUserData();

          // Start polling untuk notifikasi hasil analisis baru
          NotificationService.startPolling();
          print('🔔 Notification polling started');

          setState(() => _isLoading = false);

          // Login berhasil, navigasi ke MainScreen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const MainScreen(),
            ),
          );
        } else {
          setState(() => _isLoading = false);
          // Login gagal - tampilkan "Tidak ada akun"
          _showError('Tidak ada akun. Periksa email dan password Anda.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Terjadi kesalahan: ${e.toString()}');
      }
    }
  }

  // Load user data setelah login (NEW API STRUCTURE)
  Future<void> _loadUserData() async {
    try {
      print('🔄 Fetching user data from API...');
      final response = await ApiService.getPatientHistory();

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        // Sync patient data (including tbcareProfile) ke UserDataService
        if (data['patient'] != null) {
          UserDataService.syncFromAPI(data['patient']);
          print('✅ User data synced successfully (with tbcareProfile)');
          print('   Name: ${UserDataService.fullName}');
          print('   Email: ${UserDataService.email}');
          print('   Age: ${UserDataService.age}, Sex: ${UserDataService.sex}');
          print(
              '   BMI: ${UserDataService.bmi}, Weight: ${UserDataService.weight}kg');
        }

        // NEW: Use first history item as "firstExam" for notifications/warning
        if (data['history'] != null &&
            data['history'] is List &&
            (data['history'] as List).isNotEmpty) {
          final firstHistoryItem = (data['history'] as List)[0];
          UserDataService.setFirstExamData(firstHistoryItem);
          UserDataService.setHistoryData(data['history']);
          print('✅ First history item saved as firstExam');
          print('   ID: ${firstHistoryItem['_id']}');
          print('   Result: ${firstHistoryItem['result']}');
          print('   Total history: ${(data['history'] as List).length} items');
        } else {
          UserDataService.setFirstExamData(null);
          UserDataService.setHistoryData([]);
          print('⚠️ No history available yet');
        }
      } else {
        print('⚠️ No patient data available yet');
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      // Tidak perlu throw error, biarkan user masuk meskipun data gagal load
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Hello!',
          style: GoogleFonts.poppins(
            color: const Color(0xFF00A8C5),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF00A8C5)),
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
                color: const Color(0xFFF39C12),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Email or Mobile Number',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xFF00A8C5),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
              decoration: _inputDecoration('example@example.com'),
            ),
            const SizedBox(height: 20),
            Text(
              'Password',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xFF00A8C5),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              enabled: !_isLoading,
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
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1CB5E0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
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
