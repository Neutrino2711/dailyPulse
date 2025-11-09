import 'package:cloud_firestore/cloud_firestore.dart';

class MoodEntry {
  final String emoji;
  final String note;
  final DateTime date;

  MoodEntry({required this.emoji, required this.note, required this.date});

  Map<String, dynamic> toMap() {
    return {'emoji': emoji, 'note': note, 'date': date};
  }

  factory MoodEntry.fromFirestore(Map<String, dynamic> map) {
    return MoodEntry(
      emoji: map['emoji'] ?? '',
      note: map['note'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}
