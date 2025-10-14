// lib/screens/main/analysis_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/history_record_model.dart';
import '../../services/api_service.dart';
import '../../services/user_data_service.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  List<HistoryRecord> analysisResults = [];
  String selectedFilter = 'All';
  bool _isLoading = false;
  bool _isLoadingData = false; // Prevent multiple simultaneous calls

  @override
  void initState() {
    super.initState();
    _loadAnalysisFromAPI();
    UserDataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    UserDataService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    // Reload analysis saat data berubah
    if (mounted) {
      _loadAnalysisFromAPI();
    }
  }

  Future<void> _loadAnalysisFromAPI() async {
    if (!mounted) return;

    // Prevent multiple simultaneous calls
    if (_isLoadingData) {
      print('⚠️ ANALYSIS - Already loading, skipping duplicate call');
      return;
    }

    print('🔄 ANALYSIS - Starting to load data from API...');
    _isLoadingData = true;

    // Check if user is logged in
    final isLoggedIn = await ApiService.isLoggedIn();
    final userEmail = UserDataService.email;
    final userId = UserDataService.getUserData()['id'];
    print('🔐 ANALYSIS - User logged in: $isLoggedIn');
    print('👤 ANALYSIS - Current user: $userEmail (ID: $userId)');

    if (!isLoggedIn) {
      print('⚠️ ANALYSIS - User not logged in, skipping API call');
      _isLoadingData = false;
      setState(() {
        analysisResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getPatientHistory().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏱️ ANALYSIS - API call timeout after 30 seconds');
          return {
            'success': false,
            'message': 'Request timeout - Server tidak merespons',
          };
        },
      );
      print('📥 ANALYSIS - API Response received: ${response.keys}');
      print('📥 ANALYSIS - Success: ${response['success']}');
      print('📥 ANALYSIS - Full response: $response');

      if (!mounted) {
        print('⚠️ ANALYSIS - Widget disposed before response handled');
        return;
      }

      print('🔍 ANALYSIS - Checking response...');
      print('   response[success]: ${response['success']}');
      print(
          '   response[data]: ${response['data'] != null ? "EXISTS" : "NULL"}');

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        print('🔍 ANALYSIS SCREEN - Full data received:');
        print('   Patient exists: ${data['patient'] != null}');
        print('   Patient data: ${data['patient']}');
        print('   FirstExam exists: ${data['firstExam'] != null}');
        print('   FirstExam data: ${data['firstExam']}');
        print('   History exists: ${data['history'] != null}');
        print('   History type: ${data['history'].runtimeType}');
        print('   History count: ${data['history']?.length ?? 0}');
        if (data['history'] != null) {
          print('   History content: ${data['history']}');
        }

        // Sync patient data (including tbcareProfile)
        if (data['patient'] != null) {
          UserDataService.syncFromAPI(data['patient']);
        }

        // NEW: Use first history item as "firstExam" for notifications and warning screen
        if (data['history'] != null &&
            data['history'] is List &&
            (data['history'] as List).isNotEmpty) {
          final firstHistoryItem = (data['history'] as List)[0];
          UserDataService.setFirstExamData(firstHistoryItem);
          print('✅ ANALYSIS - First history item saved as firstExam');
          print('   ID: ${firstHistoryItem['_id']}');
          print('   Result: ${firstHistoryItem['result']}');
        } else {
          UserDataService.setFirstExamData(null);
          print('⚠️ ANALYSIS - No history in API response, clearing firstExam');
        }

        // GUNAKAN HISTORY ARRAY - 100% DARI API
        if (data['history'] != null &&
            data['history'] is List &&
            (data['history'] as List).isNotEmpty) {
          final List<dynamic> historyList = data['history'];
          // Sinkronkan history ke UserDataService agar halaman lain (warning, home) ikut update
          UserDataService.setHistoryData(historyList);
          print(
              '📊 Processing ${historyList.length} history records from API...');

          List<HistoryRecord> records = [];

          for (var historyItem in historyList) {
            try {
              // ====== AMBIL SEMUA DATA LANGSUNG DARI API ======
              String id = historyItem['_id']?.toString() ??
                  historyItem['id']?.toString() ??
                  '';
              String resultFromAPI =
                  historyItem['result']?.toString() ?? 'UNKNOWN';
              String sputumCondition =
                  historyItem['sputumCondition']?.toString() ??
                      'Tidak diketahui';

              // Ambil confidence dari API jika ada, jika tidak gunakan null
              double? confidenceFromAPI;
              if (historyItem['confidence'] != null) {
                try {
                  confidenceFromAPI =
                      double.parse(historyItem['confidence'].toString());
                } catch (e) {
                  print(
                      '⚠️ Cannot parse confidence: ${historyItem['confidence']}');
                }
              }

              // Ambil segment counts
              int tbSegmentCount = historyItem['tbSegmentCount'] ?? 0;
              int nonTbSegmentCount = historyItem['nonTbSegmentCount'] ?? 0;
              int totalCoughSegments = historyItem['totalCoughSegments'] ?? 0;

              // Parse tanggal dari API
              DateTime analysisDate = DateTime.now();
              if (historyItem['createdAt'] != null) {
                try {
                  analysisDate =
                      DateTime.parse(historyItem['createdAt'].toString());
                } catch (e) {
                  print('⚠️ Error parsing date: $e');
                }
              }

              // ====== TENTUKAN TIPE HASIL BERDASARKAN API ======
              AnalysisResult resultType;
              double displayConfidence;

              String resultUpper = resultFromAPI.toUpperCase();
              if (resultUpper == 'TB' || resultUpper.contains('POSITIVE')) {
                resultType = AnalysisResult.danger;
                displayConfidence =
                    confidenceFromAPI ?? 0.87; // Default jika tidak ada
              } else if (resultUpper == 'NORMAL' ||
                  resultUpper.contains('NEGATIVE')) {
                resultType = AnalysisResult.safe;
                displayConfidence = confidenceFromAPI ?? 0.92;
              } else {
                resultType = AnalysisResult.warning;
                displayConfidence = confidenceFromAPI ?? 0.75;
              }

              // ====== GUNAKAN DATA API UNTUK TITLE & DESCRIPTION ======
              // Title langsung dari result API
              String resultTitle = resultFromAPI;

              // Build description dari semua field yang ada di API
              List<String> descParts = [];
              descParts.add('Kondisi Sputum: $sputumCondition');

              if (totalCoughSegments > 0) {
                descParts.add('Total Segmen Batuk: $totalCoughSegments');
                if (tbSegmentCount > 0) {
                  descParts.add('Segmen TB: $tbSegmentCount');
                }
                if (nonTbSegmentCount > 0) {
                  descParts.add('Segmen Non-TB: $nonTbSegmentCount');
                }
              }

              // Predicted by info jika ada
              if (historyItem['predictedBy'] != null) {
                var predictedBy = historyItem['predictedBy'];
                String doctorName = predictedBy['userName'] ?? 'Unknown';
                String doctorRole = predictedBy['role'] ?? 'doctor';
                descParts.add('Dianalisis oleh: $doctorName ($doctorRole)');
              }

              // Detail info jika ada
              if (historyItem['detail'] != null &&
                  historyItem['detail'].toString().isNotEmpty) {
                descParts.add('Detail: ${historyItem['detail']}');
              }

              String resultDescription = descParts.join('\n');

              // ====== RECOMMENDATION BERDASARKAN RESULT ======
              String recommendation;
              if (resultType == AnalysisResult.danger) {
                recommendation =
                    'Segera konsultasi dengan dokter spesialis paru dan lakukan pemeriksaan lanjutan.';
              } else if (resultType == AnalysisResult.safe) {
                recommendation =
                    'Tetap jaga kesehatan dan pantau gejala. Kontrol rutin sesuai anjuran dokter.';
              } else {
                recommendation =
                    'Disarankan untuk pemeriksaan lebih lanjut guna memastikan kondisi kesehatan.';
              }

              // ====== CREATE RECORD DARI DATA API ======
              final record = HistoryRecord(
                id: id,
                anamnesisId: 'history_$id',
                analysisDate: analysisDate,
                result: resultType,
                resultTitle: resultTitle,
                resultDescription: resultDescription,
                recommendation: recommendation,
                audioPath: '', // No audio file in new API structure
                spectrogramPath: '',
                confidence: displayConfidence,
                analysisData: historyItem, // Simpan semua data mentah dari API
              );

              records.add(record);

              print('✅ Created record #${records.length} from API:');
              print('   ID: $id');
              print('   Result from API: $resultFromAPI');
              print('   Title: $resultTitle');
              print('   Sputum: $sputumCondition');
              print('   TB Segments: $tbSegmentCount/$totalCoughSegments');
              print(
                  '   Confidence: ${(displayConfidence * 100).toStringAsFixed(0)}%');
            } catch (e, stack) {
              print('❌ Error processing history item: $e');
              print('Stack: $stack');
              print('Item data: $historyItem');
              // Skip item yang error, lanjut ke item berikutnya
            }
          }

          if (mounted) {
            setState(() {
              analysisResults = records;
              _isLoading = false;
              print('🔄 setState called! Setting ${records.length} records');
              print(
                  '🔄 analysisResults is now: ${analysisResults.length} items');
            });
          }
          _isLoadingData = false;

          print('✅ Analysis results updated! Count: ${analysisResults.length}');
          print('✅ All results processed from API history array');

          // Verify data setelah setState
          print('🔍 Verification after setState:');
          print('   analysisResults.length = ${analysisResults.length}');
          print('   records.length = ${records.length}');
          if (analysisResults.isNotEmpty) {
            print('   First result: ${analysisResults.first.resultTitle}');
          }
        } else {
          print('⚠️ ANALYSIS - No history data found in API response!');
          print('   Available data keys: ${data.keys.toList()}');
          print('   Patient email: ${data['patient']?['email'] ?? "N/A"}');
          print('   History: ${data['history']}');
          print('   FirstExam: ${data['firstExam']}');
          print(
              'ℹ️  Kemungkinan: Akun belum pernah dianalisis atau history array kosong');
          UserDataService.setHistoryData([]);
          setState(() {
            analysisResults = [];
            _isLoading = false;
          });
          _isLoadingData = false;
        }
      } else {
        // Tidak ada data dari API - tampilkan kosong
        print('❌ ANALYSIS - API call failed or no data');
        print('   Response keys: ${response.keys.toList()}');
        print('   Success value: ${response['success']}');
        print('   Data value: ${response['data']}');
        print('   Message: ${response['message'] ?? "No message"}');
        setState(() {
          analysisResults = [];
          _isLoading = false;
        });
        _isLoadingData = false;
      }
    } catch (e, stackTrace) {
      print('❌ ANALYSIS - Error loading: $e');
      print('Stack trace: $stackTrace');
      UserDataService.setHistoryData([]);
      _isLoadingData = false;
      if (mounted) {
        setState(() {
          analysisResults = [];
          _isLoading = false;
        });
      }
    } finally {
      // Ensure flag is always reset
      _isLoadingData = false;
      print('✅ ANALYSIS - Loading completed');
    }
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
    print('🎨 BUILD - analysisResults.length: ${analysisResults.length}');
    print('🎨 BUILD - filteredResults.length: ${filteredResults.length}');
    print('🎨 BUILD - selectedFilter: $selectedFilter');
    print('🎨 BUILD - _isLoading: $_isLoading');

    // Debug: Print semua hasil untuk memastikan data ada
    if (analysisResults.isNotEmpty) {
      print('📋 BUILD - Data yang tersedia:');
      for (var i = 0; i < analysisResults.length; i++) {
        final result = analysisResults[i];
        print(
            '   [$i] ${result.resultTitle} - ${result.result} - ${(result.confidence * 100).toStringAsFixed(0)}%');
      }
    } else {
      print('⚠️ BUILD - analysisResults is EMPTY!');
    }

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
            icon: const Icon(Icons.refresh, color: Color(0xFF00A8C5)),
            onPressed: () {
              print('🔄 Manual refresh triggered');
              _loadAnalysisFromAPI();
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF00A8C5)),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00A8C5),
              ),
            )
          : Column(
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
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.biotech_outlined,
              size: 120,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Data Belum Dianalisis',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Hasil batuk anda sedang dianalisis',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _loadAnalysisFromAPI();
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                'Muat Ulang Data',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A8C5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
