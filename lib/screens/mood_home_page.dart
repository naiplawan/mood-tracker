import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../services/mood_storage.dart';
import '../widgets/add_mood_dialog.dart';
import '../widgets/mood_card.dart';
import '../widgets/empty_state_widget.dart';
import '../constants/mood_data.dart';
import 'login_page.dart';
import 'analytics_page.dart';
import 'calendar_page.dart';
import 'settings_page.dart';

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
  }  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onError,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.onTertiary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
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
          icon: Icon(
            Icons.insights_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          title: Text(
            'Your Mood Insights',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary stats
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.mood_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total entries',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${moodEntries.length}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Mood breakdown
                Text(
                  'Mood breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ...moodCounts.entries.map((entry) {
                  final moodColor = MoodData.getMoodColor(entry.key);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: moodColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              MoodData.getMoodEmoji(entry.key),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: moodColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${entry.value}',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: moodColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
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
  }  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.logout_outlined,
          color: Theme.of(context).colorScheme.error,
          size: 24,
        ),
        title: Text(
          'Sign out',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: Text(
          'Are you sure you want to sign out of your account?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
  @override  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Notes'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        actions: [
          if (moodEntries.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalendarPage(moodEntries: moodEntries),
                  ),
                );
              },
              tooltip: 'Calendar view',
            ),
            IconButton(
              icon: const Icon(Icons.analytics_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnalyticsPage(moodEntries: moodEntries),
                  ),
                );
              },
              tooltip: 'Analytics',
            ),
          ],
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(moodEntries: moodEntries),
                    ),
                  );
                  break;
                case 'insights':
                  _showMoodSummary();
                  break;
                case 'logout':
                  _handleLogout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (moodEntries.isNotEmpty)
                const PopupMenuItem(
                  value: 'insights',
                  child: ListTile(
                    leading: Icon(Icons.insights_outlined),
                    title: Text('Quick Insights'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sign out'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMoodDialog,
        tooltip: 'Add mood',
        icon: const Icon(Icons.add),
        label: const Text('Add mood'),
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
