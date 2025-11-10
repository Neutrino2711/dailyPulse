import 'package:daily_pulse/constants/consts.dart';
import 'package:daily_pulse/models/mood_analytics.dart';
import 'package:daily_pulse/models/mood_model.dart';
import 'package:daily_pulse/widgets/empty_list_widget.dart';
import 'package:daily_pulse/widgets/mood_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_pulse/blocs/bloc/moodbloc_bloc.dart';
import 'package:daily_pulse/presentation/add_mood_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MoodListScreen extends StatelessWidget {
  final String email;

  const MoodListScreen({super.key, required this.email});

  // String _formatDate(DateTime date) {
  //   return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            // light teal
            Color(0xFF252525),
            Color(0xFF252525),
            Color(0xFF242424),
            Color(0xFF2C2C2C),
            Color(0xFF3B3E3B), // cyan blue
            Color(0xFF444444),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(
                "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
              ),
            ),
          ),

          title: const Text(
            "DailyPulse",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          elevation: 0,
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              backgroundColor: Colors.black26,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddMoodScreen(email: email),
                  ),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
            const SizedBox(width: 12),
            FloatingActionButton(
              heroTag: 'clear',
              backgroundColor: Colors.black26,
              onPressed: () async {
                final box = Hive.box<MoodEntry>('moods');
                await box.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Local Hive data cleared!')),
                );
              },
              child: const Icon(Icons.delete_forever, color: Colors.white),
            ),
          ],
        ),
        body: BlocBuilder<MoodblocBloc, MoodblocState>(
          builder: (context, state) {
            if (state is MoodLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MoodLoaded) {
              if (state.entries.isEmpty) {
                return EmptyMoodListWidget();
              }
              // final counts = <String, int>{};
              // var positive = 0;
              // for (final entry in state.entries) {
              //   counts[entry.emoji] = (counts[entry.emoji] ?? 0) + 1;
              //   if (positiveEmojis.contains(entry.emoji)) positive++;
              // }
              // final analytics = MoodAnalytics(
              //   total: state.entries.length,
              //   countsByEmoji: counts,
              //   positiveCount: positive,
              // );
              final analytics =
                  state.analytics ?? _deriveAnalyticsFromEntries(state.entries);
              return MoodListWidget(
                entries: state.entries,
                analytics: analytics,
              );
            }

            if (state is MoodError) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: Colors.red.shade400),
                ),
              );
            }
            debugPrint('Unknown state: $state');
            return const Center(child: Text('Something went wrong'));
          },
        ),
      ),
    );
  }
}

MoodAnalytics _deriveAnalyticsFromEntries(List<MoodEntry> entries) {
  final counts = <String, int>{};
  var positive = 0;
  for (final entry in entries) {
    counts[entry.emoji] = (counts[entry.emoji] ?? 0) + 1;
    if (positiveEmojis.contains(entry.emoji)) positive++;
  }
  return MoodAnalytics(
    total: entries.length,
    countsByEmoji: counts,
    positiveCount: positive,
  );
}
