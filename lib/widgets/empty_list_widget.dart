import 'package:flutter/material.dart';

class EmptyMoodListWidget extends StatelessWidget {
  const EmptyMoodListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mood, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No mood entries yet',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first mood',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
