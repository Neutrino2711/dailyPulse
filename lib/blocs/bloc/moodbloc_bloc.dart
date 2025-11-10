import 'package:bloc/bloc.dart';
import 'package:daily_pulse/constants/consts.dart';
import 'package:daily_pulse/models/mood_analytics.dart';
import 'package:equatable/equatable.dart';
import 'package:daily_pulse/models/mood_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';

part 'moodbloc_event.dart';
part 'moodbloc_state.dart';

class MoodblocBloc extends Bloc<MoodblocEvent, MoodblocState> {
  MoodblocBloc() : super(MoodblocInitial()) {
    on<SaveMood>(_onSaveMood);
    on<LoadMoods>(_onLoadMoods);
    on<AnalyzeMoods>(_onAnalyzeMoods);
  }

  final List<MoodEntry> _entries = [];

  Future<void> _onSaveMood(SaveMood event, Emitter<MoodblocState> emit) async {
    emit(MoodLoading());
    try {
      final now = DateTime.now();
 
      final entry = MoodEntry(
        emoji: event.mood,
        note: event.note ?? '',
        date: now,
      );

      final box = Hive.box<MoodEntry>('moods');
      await box.add(entry);

      
      await _saveMoodToFirestore(
        email: event.email,
        emoji: event.mood,
        note: event.note ?? '',
        date: now,
      );

      
      _entries.insert(0, entry);
      debugPrint(_entries.toString());
      emit(MoodLoaded(entries: List.from(_entries)));
      add(const AnalyzeMoods());
    } catch (e) {
      emit(MoodError('Failed to save mood: ${e.toString()}'));
    }
  }

  Future<void> _saveMoodToFirestore({
    required String email,
    required String emoji,
    required String note,
    required DateTime date,
  }) async {
   
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(email);

  
    await userDocRef.collection('moods').add({
      'emoji': emoji,
      'note': note,
      'date': date,
    });
  }

  Future<void> _onLoadMoods(
    LoadMoods event,
    Emitter<MoodblocState> emit,
  ) async {
    emit(MoodLoading());
    try {
    

      List<MoodEntry> entries = [];
      try {
        debugPrint("I am here");
        final moodsRef = FirebaseFirestore.instance
            .collection('users')
            .doc(event.email)
            .collection('moods');

       
        final querySnapshot = await moodsRef
            .orderBy('date', descending: true)
            .get();

        debugPrint(
          "Query snapshot received with ${querySnapshot.docs.first.data()} documents",
        );
       
        entries = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return MoodEntry(
            emoji: data['emoji'] as String,
            note: data['note'] as String,
            date: (data['date'] as Timestamp).toDate(),
          );
        }).toList();
        debugPrint(entries.toString());

        final box = Hive.box<MoodEntry>('moods');
        // await box.clear();
        // await box.addAll(entries);
        debugPrint("Entries saved to Hive: ${box.values.single}");
      } catch (e) {
        print('Loading from Firestore failed: $e');
        final box = Hive.box<MoodEntry>('moods');
        entries = box.values.toList();
      }

      
      _entries.clear();
      _entries.addAll(entries);
      debugPrint(entries.toString());
      emit(MoodLoaded(entries: List.from(_entries)));
      add(const AnalyzeMoods());
    } catch (e) {
      emit(MoodError('Failed to load moods: ${e.toString()}'));
    }
  }

  Future<void> _onAnalyzeMoods(
    AnalyzeMoods event,
    Emitter<MoodblocState> emit,
  ) async {
    try {
      
      final entries = List<MoodEntry>.from(_entries);
      final counts = <String, int>{};
      var positive = 0;
      for (final e in entries) {
        final emoji = e.emoji.trim();
        counts[emoji] = (counts[emoji] ?? 0) + 1;
        if (positiveEmojis.contains(emoji)) positive++;
      }
      final analytics = MoodAnalytics(
        total: entries.length,
        countsByEmoji: counts,
        positiveCount: positive,
      );
      emit(MoodLoaded(entries: entries, analytics: analytics));
    } catch (e) {
      
      emit(MoodError('Failed to compute analytics: ${e.toString()}'));
    }
  }
}
