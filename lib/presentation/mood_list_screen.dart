import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_pulse/blocs/bloc/moodbloc_bloc.dart';
import 'package:daily_pulse/presentation/add_mood_screen.dart';

const Map<int, String> monthNames = {
  1: 'January',
  2: 'February',
  3: 'March',
  4: 'April',
  5: 'May',
  6: 'June',
  7: 'July',
  8: 'August',
  9: 'September',
  10: 'October',
  11: 'November',
  12: 'December',
};

List<Color> colors = [
  Colors.orange.shade500,
  Colors.yellow.shade500,
  Colors.green.shade500,
  Colors.blue.shade500,
  Colors.indigo.shade500,
  Colors.purple.shade500,
  Colors.pink.shade500,
];

class MoodListScreen extends StatelessWidget {
  final String email;

  const MoodListScreen({super.key, required this.email});

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddMoodScreen(email: email),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<MoodblocBloc, MoodblocState>(
          builder: (context, state) {
            if (state is MoodLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MoodLoaded) {
              if (state.entries.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mood, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No mood entries yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to add your first mood',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Text(
                    "Good to see you back!",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white54,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12.0,
                    ),
                    child: Text(
                      "Don't let a bad day in life make you feel like you have a bad life",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.entries.length,
                      itemBuilder: (context, index) {
                        final entry = state.entries[index];
                        final previousEntry = index > 0
                            ? state.entries[index - 1]
                            : null;

                        bool isNewMonth =
                            previousEntry == null ||
                            entry.date.month != previousEntry.date.month ||
                            entry.date.year != previousEntry.date.year;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isNewMonth) ...[
                              const SizedBox(
                                height: 24,
                              ), // extra margin before new month
                              Text(
                                '${monthNames[entry.date.month]} ${entry.date.year}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: colors[index % colors.length],
                              child: ListTile(
                                leading: Column(
                                  children: [
                                    Text(
                                      entry.date.day.toString(),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      monthNames[entry.date.month]!.substring(
                                        0,
                                        3,
                                      ),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),

                                title: Row(
                                  children: [
                                    Text(
                                      entry.note,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      entry.emoji,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                  entry.note,
                                  style: TextStyle(color: Colors.grey.shade200),
                                ),
                                // subtitle: Text(
                                //   _formatDate(entry.date),
                                //   style: TextStyle(color: Colors.grey.shade600),
                                // ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
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

            return const Center(child: Text('Something went wrong'));
          },
        ),
      ),
    );
  }
}
