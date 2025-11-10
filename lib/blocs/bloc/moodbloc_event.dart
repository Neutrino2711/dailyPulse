part of 'moodbloc_bloc.dart';

sealed class MoodblocEvent extends Equatable {
  const MoodblocEvent();

  @override
  List<Object> get props => [];
}

final class SaveMood extends MoodblocEvent {
  final String email;
  final String mood;
  final String? note;

  const SaveMood({required this.email, required this.mood, this.note});

  @override
  List<Object> get props => [email, mood, note ?? ''];
}

final class LoadMoods extends MoodblocEvent {
  final String email;

  const LoadMoods(this.email);

  @override
  List<Object> get props => [email];
}

final class AnalyzeMoods extends MoodblocEvent {
  const AnalyzeMoods();
}
