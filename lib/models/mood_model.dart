import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'mood_model.g.dart';

@HiveType(typeId: 0)
class MoodEntry {
  @HiveField(0)
  final String emoji;

  @HiveField(1)
  final String note;

  @HiveField(2)
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
