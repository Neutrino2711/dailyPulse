part of 'moodbloc_bloc.dart';

sealed class MoodblocState extends Equatable {
  const MoodblocState();

  @override
  List<Object> get props => [];
}

final class MoodblocInitial extends MoodblocState {}

final class MoodLoaded extends MoodblocState {
  final List<MoodEntry> entries;
  final MoodAnalytics? analytics; // new optional field

  const MoodLoaded({this.entries = const [], this.analytics});

  @override
  List<Object> get props => [entries, if (analytics != null) analytics!];
}

final class MoodError extends MoodblocState {
  final String message;

  const MoodError(this.message);

  @override
  List<Object> get props => [message];
}

final class MoodLoading extends MoodblocState {}

final class MoodAnalyticsLoaded extends MoodblocState {
  final MoodAnalytics analytics;
  const MoodAnalyticsLoaded({required this.analytics});

  @override
  List<Object> get props => [analytics];
}
