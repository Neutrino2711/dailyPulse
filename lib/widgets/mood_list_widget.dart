import 'package:daily_pulse/constants/consts.dart';
import 'package:daily_pulse/models/mood_analytics.dart';
import 'package:daily_pulse/models/mood_model.dart';
import 'package:flutter/material.dart';

class MoodListWidget extends StatelessWidget {
  const MoodListWidget({
    super.key,
    required this.analytics,
    required this.entries,
  });

  final MoodAnalytics analytics;
  final List<MoodEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Good to see you back!",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Colors.white54,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
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

        // Analytics summary for the loaded moods
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _buildAnalytics(analytics),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final previousEntry = index > 0 ? entries[index - 1] : null;

              bool isNewMonth =
                  previousEntry == null ||
                  entry.date.month != previousEntry.date.month ||
                  entry.date.year != previousEntry.date.year;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isNewMonth) ...[
                    const SizedBox(height: 24), // extra margin before new month
                    Text(
                      '${monthNames[entry.date.month]} ${entry.date.year}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
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
                            monthNames[entry.date.month]!.substring(0, 3),
                            style: const TextStyle(fontSize: 6),
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
}

Widget _buildAnalytics(MoodAnalytics analytics) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Total: ${analytics.total}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Text(
              'Positive: ${analytics.positiveCount}',
              style: TextStyle(color: Colors.green[700]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: analytics.countsByEmoji.entries.map((e) {
            return Chip(
              label: Text('${e.key}  ${e.value}'),
              backgroundColor: Colors.teal.shade50,
            );
          }).toList(),
        ),
      ],
    ),
  );
}
