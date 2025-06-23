import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../services/mood_storage.dart';
import '../widgets/add_mood_dialog.dart';
import '../widgets/mood_card.dart';
import '../widgets/empty_state_widget.dart';
import '../services/theme_service.dart';
import '../utils/animations.dart';

class MoodHomePage extends StatefulWidget {
  final List<MoodEntry> moodEntries;
  final VoidCallback onMoodUpdated;

  const MoodHomePage({
    super.key,
    required this.moodEntries,
    required this.onMoodUpdated,
  });

  @override
  State<MoodHomePage> createState() => _MoodHomePageState();
}

class _MoodHomePageState extends State<MoodHomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F172A),
            const Color(0xFF1E293B),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Mood Tracker',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: widget.moodEntries.isEmpty
                ? const EmptyStateWidget()
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.moodEntries.length,
                    itemBuilder: (context, index) {
                      final entry = widget.moodEntries[index];
                      return MoodCard(
                        entry: entry,
                        onDelete: () => _deleteMoodEntry(entry),
                      );
                    },
                  ),
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return GlowAnimation(
      glowColor: Theme.of(context).primaryColor.withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
          gradient: ThemeService.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showAddMoodDialog,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add Mood',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddMoodDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AddMoodDialog(
        onAddMood: (mood, emoji, note) async {          final newEntry = MoodEntry(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            mood: mood,
            emoji: emoji,
            note: note,
            timestamp: DateTime.now(),
          );
          
          final updatedEntries = [newEntry, ...widget.moodEntries];
          await MoodStorage.saveMoodEntries(updatedEntries);
          widget.onMoodUpdated();
        },
      ),
    );
  }

  Future<void> _deleteMoodEntry(MoodEntry entry) async {
    final index = widget.moodEntries.indexOf(entry);
    if (index == -1) return;
    
    try {
      final updatedEntries = List<MoodEntry>.from(widget.moodEntries)..removeAt(index);
      await MoodStorage.saveMoodEntries(updatedEntries);
      widget.onMoodUpdated();
    } catch (e) {
      // Show error
    }
  }
}
