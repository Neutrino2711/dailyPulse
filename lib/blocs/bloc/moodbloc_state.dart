part of 'moodbloc_bloc.dart';

sealed class MoodblocState extends Equatable {
  const MoodblocState();

  @override
  List<Object> get props => [];
}

final class MoodblocInitial extends MoodblocState {}

final class MoodLoaded extends MoodblocState {
  final List<MoodEntry> entries;

  const MoodLoaded({this.entries = const []});

  @override
  List<Object> get props => [entries];
}

final class MoodError extends MoodblocState {
  final String message;

  const MoodError(this.message);

  @override
  List<Object> get props => [message];
}

final class MoodLoading extends MoodblocState {}
