import 'package:daily_pulse/blocs/bloc/moodbloc_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AddMoodScreen extends StatefulWidget {
  final String email;
  const AddMoodScreen({super.key, required this.email});

  @override
  State<AddMoodScreen> createState() => _AddMoodScreenState();
}

class _AddMoodScreenState extends State<AddMoodScreen> {
  final TextEditingController _noteController = TextEditingController();
  String? _selectedEmoji;

  final moods = ["😊", "😐", "😔", "😡", "😴"];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Entry"), elevation: 0),
      body: BlocListener<MoodblocBloc, MoodblocState>(
        listener: (context, state) {
          if (state is MoodLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Mood saved successfully!")),
            );
            if (Navigator.canPop(context)) {
              Navigator.pop(context); // Go back to the list screen
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "How are you feeling today?",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 15,
                children: moods.map((emoji) {
                  final selected = _selectedEmoji == emoji;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.blue.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 26)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Write a short note...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const Spacer(),
              BlocBuilder<MoodblocBloc, MoodblocState>(
                builder: (context, state) {
                  if (state is MoodLoading) {
                    return const CircularProgressIndicator();
                  }
                  return ElevatedButton(
                    onPressed: _selectedEmoji == null
                        ? null
                        : () {
                            context.read<MoodblocBloc>().add(
                              SaveMood(
                                email: widget.email,
                                mood: _selectedEmoji!,
                                note: _noteController.text.trim(),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text("Save Entry"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
