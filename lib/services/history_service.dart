// lib/services/history_service.dart
import 'package:flutter/material.dart';
import '../models/history_record_model.dart';

class HistoryService {
  static final List<HistoryRecord> _records = [];
  static final List<VoidCallback> _listeners = [];

  // Initialize with dummy data
  static void initializeDummyData() {
    if (_records.isEmpty) {
      _records.addAll([
        HistoryRecord(
          id: '1',
          anamnesisId: 'anm_001',
          analysisDate: DateTime.now().subtract(Duration(hours: 2)),
          result: AnalysisResult.danger,
          resultTitle: 'Terindikasi Positif TBC',
          resultDescription:
              'Berdasarkan analisis suara batuk, ditemukan pola yang mengarah pada indikasi TBC.',
          recommendation:
              'Segera konsultasikan dengan dokter untuk pemeriksaan lebih lanjut. Lakukan tes dahak dan rontgen dada.',
          audioPath: 'assets/audio/cough_sample_1.wav',
          spectrogramPath: 'assets/images/spectrogram_1.png',
          confidence: 0.87,
          analysisData: {
            'frequency_peak': '150-300 Hz',
            'duration': '2.3s',
            'intensity': 'Tinggi',
          },
        ),
        HistoryRecord(
          id: '2',
          anamnesisId: 'anm_002',
          analysisDate: DateTime.now().subtract(Duration(days: 1)),
          result: AnalysisResult.warning,
          resultTitle: 'Perlu Pengawasan',
          resultDescription:
              'Ditemukan beberapa karakteristik yang perlu diwaspadai pada pola suara batuk.',
          recommendation:
              'Monitor kondisi selama 1-2 minggu. Jika gejala bertambah, segera konsultasi dokter.',
          audioPath: 'assets/audio/cough_sample_2.wav',
          spectrogramPath: 'assets/images/spectrogram_2.png',
          confidence: 0.65,
          analysisData: {
            'frequency_peak': '100-250 Hz',
            'duration': '1.8s',
            'intensity': 'Sedang',
          },
        ),
        HistoryRecord(
          id: '3',
          anamnesisId: 'anm_003',
          analysisDate: DateTime.now().subtract(Duration(days: 3)),
          result: AnalysisResult.safe,
          resultTitle: 'Kondisi Normal',
          resultDescription:
              'Pola suara batuk menunjukkan karakteristik normal tanpa indikasi TBC.',
          recommendation:
              'Tetap jaga kesehatan dengan pola hidup sehat dan istirahat cukup.',
          audioPath: 'assets/audio/cough_sample_3.wav',
          spectrogramPath: 'assets/images/spectrogram_3.png',
          confidence: 0.92,
          analysisData: {
            'frequency_peak': '80-150 Hz',
            'duration': '1.2s',
            'intensity': 'Rendah',
          },
        ),
      ]);
    }
  }

  static List<HistoryRecord> getAllRecords() {
    return List.from(_records);
  }

  static void addRecord(HistoryRecord record) {
    _records.insert(0, record);
    _notifyListeners();
  }

  static void deleteRecord(String id) {
    _records.removeWhere((record) => record.id == id);
    _notifyListeners();
  }

  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}
