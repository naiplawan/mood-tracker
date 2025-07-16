import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mood_entry.dart';
import '../widgets/add_mood_dialog.dart';
import '../widgets/mood_card.dart';
import '../widgets/empty_state_widget.dart';
import '../services/theme_service.dart';
import '../utils/animations.dart';
import '../viewmodels/view_models.dart';

class MoodHomePage extends StatefulWidget {
  const MoodHomePage({super.key});

  @override
  State<MoodHomePage> createState() => _MoodHomePageState();
}

class _MoodHomePageState extends State<MoodHomePage> {
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
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add Mood',
                    style: TextStyle(
                      color: Colors.white,
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
    await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AddMoodDialog(
        onAddMood: (mood, emoji, note) async {
          final moodViewModel = context.read<MoodViewModel>();
          final newEntry = MoodEntry(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            mood: mood,
            emoji: emoji,
            note: note,
            timestamp: DateTime.now(),
          );
          
          await moodViewModel.addMoodEntry(newEntry);
        },
      ),
    );
  }

  Future<void> _deleteMoodEntry(MoodEntry entry) async {
    final moodViewModel = context.read<MoodViewModel>();
    await moodViewModel.deleteMoodEntry(entry);
  }

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
            child: Consumer<MoodViewModel>(
              builder: (context, moodViewModel, child) {
                if (moodViewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                
                if (moodViewModel.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${moodViewModel.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                
                return moodViewModel.moodEntries.isEmpty
                    ? const EmptyStateWidget()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: moodViewModel.moodEntries.length,
                        itemBuilder: (context, index) {
                          final entry = moodViewModel.moodEntries[index];
                          return MoodCard(
                            entry: entry,
                            onDelete: () => _deleteMoodEntry(entry),
                          );
                        },
                      );
              },
            ),
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }
}
