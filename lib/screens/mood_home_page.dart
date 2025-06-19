import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../services/mood_storage.dart';
import '../widgets/add_mood_dialog.dart';
import '../widgets/mood_card.dart';
import '../widgets/empty_state_widget.dart';
import '../constants/mood_data.dart';

class MoodHomePage extends StatefulWidget {
  const MoodHomePage({super.key});

  @override
  State<MoodHomePage> createState() => _MoodHomePageState();
}

class _MoodHomePageState extends State<MoodHomePage> {
  List<MoodEntry> moodEntries = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadMoodEntries();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadMoodEntries() async {
    try {
      final entries = await MoodStorage.loadMoodEntries();
      setState(() {
        moodEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load mood entries');
    }
  }

  Future<void> _saveMoodEntries() async {
    try {
      await MoodStorage.saveMoodEntries(moodEntries);
    } catch (e) {
      _showErrorSnackBar('Failed to save mood entry');
    }
  }

  void _addMoodEntry(String mood, String emoji, String note) {
    final newEntry = MoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mood: mood,
      emoji: emoji,
      note: note,
      timestamp: DateTime.now(),
    );

    setState(() {
      moodEntries.insert(0, newEntry);
    });
    _saveMoodEntries();
    _showSuccessSnackBar('Mood entry added successfully!');
  }

  void _deleteMoodEntry(String id) {
    setState(() {
      moodEntries.removeWhere((entry) => entry.id == id);
    });
    _saveMoodEntries();
    _showSuccessSnackBar('Mood entry deleted');
  }
  void _showAddMoodDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddMoodDialog(onAddMood: _addMoodEntry);
      },
    );
  }
  void _showDeleteDialog(String id) {
    final entry = moodEntries.firstWhere((e) => e.id == id);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red[600]),
              const SizedBox(width: 8),
              const Text('Delete Mood Entry'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to delete this mood entry?'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(entry.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(entry.mood, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red[600],
              ),
              child: const Text('Delete'),
              onPressed: () {
                _deleteMoodEntry(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMoodSummary() {
    final moodCounts = <String, int>{};
    for (final entry in moodEntries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Your Mood Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total entries: ${moodEntries.length}'),
              const SizedBox(height: 16),
              ...moodCounts.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(MoodData.getMoodEmoji(entry.key)),
                    const SizedBox(width: 8),
                    Text(entry.key),
                    const Spacer(),
                    Text('${entry.value}x'),
                  ],
                ),
              )),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: const Text('Mood Notes'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      actions: [
        if (moodEntries.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.insights),
          onPressed: _showMoodSummary,
          tooltip: 'View mood insights',
        ),
      ],
      ),
      body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        ],
        stops: const [0.0, 0.2],
        ),
      ),
      child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
      onPressed: _showAddMoodDialog,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add_reaction),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (moodEntries.isEmpty) {
      return const EmptyStateWidget();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: moodEntries.length,
      itemBuilder: (context, index) {
        final entry = moodEntries[index];
        return MoodCard(
          entry: entry,
          onDelete: () => _showDeleteDialog(entry.id),
        );
      },
    );
  }
}
