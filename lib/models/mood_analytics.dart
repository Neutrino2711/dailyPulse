class MoodAnalytics {
  final int total;
  final Map<String, int> countsByEmoji;
  final int positiveCount;

  MoodAnalytics({
    required this.total,
    required this.countsByEmoji,
    required this.positiveCount,
  });
}
