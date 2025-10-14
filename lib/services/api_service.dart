// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL - Ganti sesuai dengan network Anda
  static const String baseUrl = 'http://10.160.10.196/api';

  // Alternative URLs untuk testing (uncomment jika perlu)
  // static const String baseUrl = 'http://192.168.1.100/api'; // Ganti dengan IP PC Anda


  // Login - Simple version
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      var headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      var request = http.Request('POST', Uri.parse('$baseUrl/admin/login'));
      request.bodyFields = {
        'email': email,
        'password': password,
      };
      request.headers.addAll(headers);

      http.StreamedResponse streamResponse = await request.send();
      final responseBody = await streamResponse.stream.bytesToString();

      print('Login Status: ${streamResponse.statusCode}');

      if (streamResponse.statusCode == 200) {
        final data = jsonDecode(responseBody);

        // Simpan token
        if (data['token'] != null) {
          String token = data['token'].toString();
          if (token.startsWith('Bearer ')) {
            token = token.substring(7);
          }
          await saveToken(token);
          print('✅ Token saved');
        }

        // Simpan user data
        if (data['userId'] != null) {
          await saveUserData({
            'id': data['userId'],
            'email': email,
          });
          print('✅ User data saved');
        }

        return {
          'success': true,
          'message': 'Login berhasil',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Login gagal',
        };
      }
    } catch (e) {
      print('❌ Login error: $e');
      return {
        'success': false,
        'message': 'Koneksi gagal: $e',
      };
    }
  }

  // Simpan token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Simpan data user
  static Future<void> saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', jsonEncode(user));
  }

  // Ambil token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Ambil user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('userData');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // Get user ID
  static Future<String?> getUserId() async {
    final userData = await getUserData();
    return userData?['id']?.toString() ?? userData?['userId']?.toString();
  }

  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Initialize - Load saved token on app start
  static Future<void> initialize() async {
    try {
      final token = await getToken();
      if (token != null) {
        print('✅ Token loaded from storage');
      } else {
        print('ℹ️ No token found, user needs to login');
      }
    } catch (e) {
      print('❌ Error initializing ApiService: $e');
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('✅ Logout success');
    } catch (e) {
      print('❌ Logout error: $e');
    }
  }

  // Ambil patient history
  static Future<Map<String, dynamic>> getPatientHistory() async {
    try {
      final token = await getToken();
      final userId = await getUserId();

      if (token != null) {
        print(
          '🔑 Token yang akan dikirim: ${token.substring(0, token.length > 50 ? 50 : token.length)}...',
        );
        print('🔑 Token length: ${token.length} characters');
      } else {
        print('🔑 Token: NULL');
      }

      if (userId != null) {
        print('👤 Patient ID: $userId');
      }

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
          'needLogin': true,
        };
      }

      // Coba dulu dengan GET tanpa body (standard REST)
      String url = '$baseUrl/tbcare/patient_history';
      if (userId != null) {
        url = '$url?patientId=$userId';
      }

      print('🌐 Request GET ke: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30), // Increase timeout to 30 seconds
        onTimeout: () {
          print('⏱️ Request timeout setelah 30 detik');
          throw Exception('Request timeout - Server tidak merespons');
        },
      );

      print('📊 Response Status: ${response.statusCode}');
      print(
        '📦 Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}',
      );
      print('📋 Response Headers: ${response.headers}');
      print('📏 Content Length: ${response.body.length} characters');

      // Cek apakah response adalah HTML (error page)
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<!doctype') ||
          response.body.trim().startsWith('<html')) {
        print('❌ Response adalah HTML, bukan JSON!');
        print(
          '🔍 Kemungkinan: Token tidak valid, endpoint salah, atau perlu login ulang',
        );
        return {
          'success': false,
          'message':
              'Server mengembalikan HTML. Token mungkin tidak valid atau expired.',
          'needLogin': true,
          'debug': 'Response: ${response.body.substring(0, 200)}...',
        };
      }

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('✅ JSON parsed successfully!');
          print('🔍 Data keys: ${data.keys.toList()}');

          // Validasi struktur response
          if (data['patient'] != null && data['history'] != null) {
            print('✅ Response structure valid!');
            print('👤 Patient: ${data['patient']['fullName']}');
            print('📋 History count: ${data['history'].length}');
          }

          return {'success': true, 'data': data};
        } catch (e) {
          print('❌ JSON parsing failed: $e');
          return {
            'success': false,
            'message': 'Gagal parse JSON response: $e',
            'rawResponse': response.body.substring(0, 200),
          };
        }
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        return {
          'success': false,
          'message': 'Sesi Anda telah berakhir. Silakan login kembali.',
          'needLogin': true,
        };
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        try {
          final data = jsonDecode(response.body);
          return {
            'success': false,
            'message': data['message'] ?? 'Error ${response.statusCode}',
          };
        } catch (e) {
          return {
            'success': false,
            'message':
                'HTTP ${response.statusCode}: ${response.body.substring(0, 100)}',
          };
        }
      }
    } catch (e) {
      print('🔴 Error get history: $e');
      print('🔴 Error type: ${e.runtimeType}');
      return {'success': false, 'message': 'Gagal mengambil data: $e'};
    }
  }

  // Test network connectivity to server
  static Future<bool> testServerConnection() async {
    try {
      print('🔍 Testing server connection to: $baseUrl');

      final response = await http
          .get(
            Uri.parse('$baseUrl/admin/login'), // Test endpoint
          )
          .timeout(const Duration(seconds: 5));

      print('✅ Server reachable! Status: ${response.statusCode}');
      return true;
    } catch (e) {
      print('❌ Server not reachable: $e');
      return false;
    }
  }

  // Test API tanpa token (untuk debugging)
  static Future<Map<String, dynamic>> testAPIWithoutToken() async {
    try {
      print('🧪 Testing API WITHOUT token...');
      print('🌐 URL: $baseUrl/tbcare/patient_history');

      final response = await http
          .get(Uri.parse('$baseUrl/tbcare/patient_history'))
          .timeout(const Duration(seconds: 10));

      print('📊 Status: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('✅ API bisa diakses TANPA token!');
          return {'success': true, 'needsAuth': false, 'data': data};
        } catch (e) {
          print('❌ Response bukan JSON: $e');
          return {'success': false, 'body': response.body};
        }
      }

      return {
        'success': response.statusCode == 200,
        'status': response.statusCode,
        'body': response.body,
      };
    } catch (e) {
      print('🔴 Error: $e');
      return {'success': false, 'message': '$e'};
    }
  }

  // Debug: Print current session info
  static Future<void> debugPrintToken() async {
    final token = await getToken();
    final userData = await getUserData();

    print('Current Token: ${token?.substring(0, 50)}...');
    print('Current User Data: $userData');
    print('Is Logged In: ${await isLoggedIn()}');
  }
}
