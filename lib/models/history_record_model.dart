// lib/models/history_record_model.dart
enum AnalysisResult {
  safe, // Hijau - Aman
  warning, // Kuning - Waspada
  danger, // Merah - Tidak Aman
}

class HistoryRecord {
  final String id;
  final String anamnesisId;
  final DateTime analysisDate;
  final AnalysisResult result;
  final String resultTitle;
  final String resultDescription;
  final String recommendation;
  final String audioPath;
  final String spectrogramPath;
  final double confidence;
  final Map<String, dynamic> analysisData;

  HistoryRecord({
    required this.id,
    required this.anamnesisId,
    required this.analysisDate,
    required this.result,
    required this.resultTitle,
    required this.resultDescription,
    required this.recommendation,
    required this.audioPath,
    required this.spectrogramPath,
    required this.confidence,
    required this.analysisData,
  });

  String get confidencePercentage => '${(confidence * 100).toInt()}%';

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(analysisDate);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
}
