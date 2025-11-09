import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:daily_pulse/models/mood_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'moodbloc_event.dart';
part 'moodbloc_state.dart';

class MoodblocBloc extends Bloc<MoodblocEvent, MoodblocState> {
  MoodblocBloc() : super(MoodblocInitial()) {
    on<SaveMood>(_onSaveMood);
    on<LoadMoods>(_onLoadMoods);
  }

  final List<MoodEntry> _entries = [];

  Future<void> _onSaveMood(SaveMood event, Emitter<MoodblocState> emit) async {
    emit(MoodLoading());
    try {
      final now = DateTime.now();
      // Create a new mood entry
      final entry = MoodEntry(
        emoji: event.mood,
        note: event.note ?? '',
        date: now,
      );

      // Save to Firestore
      await _saveMoodToFirestore(
        email: event.email,
        emoji: event.mood,
        note: event.note ?? '',
        date: now,
      );

      // Add to local list and emit new state
      _entries.insert(0, entry);
      emit(MoodLoaded(entries: List.from(_entries)));
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
    // Reference to the user's document
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(email);

    // Add mood to the moods subcollection
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
      // Reference to the user's moods collection
      final moodsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(event.email)
          .collection('moods');

      // Get all moods ordered by date
      final querySnapshot = await moodsRef
          .orderBy('date', descending: true)
          .get();

      // Convert the documents to MoodEntry objects
      final entries = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return MoodEntry(
          emoji: data['emoji'] as String,
          note: data['note'] as String,
          date: (data['date'] as Timestamp).toDate(),
        );
      }).toList();

      // Update local list and emit new state
      _entries.clear();
      _entries.addAll(entries);
      emit(MoodLoaded(entries: List.from(_entries)));
    } catch (e) {
      emit(MoodError('Failed to load moods: ${e.toString()}'));
    }
  }
}
