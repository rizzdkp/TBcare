// lib/models/anamnesis_model.dart

class Anamnesis {
  final String participantId;
  final DateTime recordingDate;
  final String sex;
  final int age;
  final double height;
  final double weight;
  final String coughDuration;
  final bool isCoughProductive;
  // ... tambahkan variabel lainnya sesuai kebutuhan
  
  Anamnesis({
    required this.participantId,
    required this.recordingDate,
    required this.sex,
    required this.age,
    required this.height,
    required this.weight,
    required this.coughDuration,
    required this.isCoughProductive,
  });
}