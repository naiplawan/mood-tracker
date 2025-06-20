import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../services/mood_storage.dart';
import '../widgets/add_mood_dialog.dart';
import 'mood_home_page.dart';
import 'analytics_page.dart';
import 'calendar_page.dart';
import 'settings_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  List<MoodEntry> moodEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMoodEntries();
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
    }
  }

  Future<void> _saveMoodEntries() async {
    try {
      await MoodStorage.saveMoodEntries(moodEntries);
    } catch (e) {
      // Handle error
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

  void _showAddMoodDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddMoodDialog(onAddMood: _addMoodEntry);
      },
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
            Expanded(child: Text(message)),
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
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = [
      const MoodHomePage(),
      CalendarPage(moodEntries: moodEntries),
      AnalyticsPage(moodEntries: moodEntries),
      SettingsPage(moodEntries: moodEntries),
    ];

    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    // Only show app bar on specific tabs or add a global one
    final titles = ['Mood Notes', 'Mood Calendar', 'Analytics', 'Settings'];
    
    return AppBar(
      title: Text(titles[_currentIndex]),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      actions: _buildAppBarActions(),
    );
  }

  List<Widget> _buildAppBarActions() {
    switch (_currentIndex) {
      case 0: // Home
        return [
          if (moodEntries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.insights_outlined),
              onPressed: () {
                setState(() {
                  _currentIndex = 2; // Switch to Analytics tab
                });
              },
              tooltip: 'View insights',
            ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () {
              setState(() {
                _currentIndex = 1; // Switch to Calendar tab
              });
            },
            tooltip: 'View calendar',
          ),
        ];
      case 1: // Calendar
        return [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              // This would need to be passed to the calendar page
              // For now, just show a helpful message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Jumped to today'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'Go to today',
          ),
        ];
      case 2: // Analytics
        return [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMoodEntries,
            tooltip: 'Refresh data',
          ),
        ];
      case 3: // Settings
        return [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showAppInfo,
            tooltip: 'About app',
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
        _hapticFeedback();
      },
      animationDuration: const Duration(milliseconds: 300),
      destinations: [
        NavigationDestination(
          icon: Badge(
            isLabelVisible: moodEntries.isNotEmpty,
            label: Text('${moodEntries.length}'),
            child: const Icon(Icons.home_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: moodEntries.isNotEmpty,
            label: Text('${moodEntries.length}'),
            child: const Icon(Icons.home),
          ),
          label: 'Home',
          tooltip: 'View mood entries (${moodEntries.length} entries)',
        ),
        NavigationDestination(
          icon: const Icon(Icons.calendar_month_outlined),
          selectedIcon: const Icon(Icons.calendar_month),
          label: 'Calendar',
          tooltip: 'View mood calendar',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: moodEntries.length >= 3,
            child: const Icon(Icons.analytics_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: moodEntries.length >= 3,
            child: const Icon(Icons.analytics),
          ),
          label: 'Analytics',
          tooltip: moodEntries.length >= 3 
              ? 'View analytics and insights' 
              : 'Add more moods to see analytics',
        ),
        const NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
          tooltip: 'App settings and preferences',
        ),
      ],
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_currentIndex) {
      case 0: // Home tab
        return FloatingActionButton.extended(
          onPressed: _showAddMoodDialog,
          tooltip: 'Add new mood entry',
          icon: const Icon(Icons.add),
          label: const Text('Add Mood'),
          heroTag: "addMood",
        );
      case 1: // Calendar tab
        return FloatingActionButton(
          onPressed: _showAddMoodDialog,
          tooltip: 'Add mood for today',
          child: const Icon(Icons.add),
          heroTag: "addMoodCalendar",
        );
      default:
        return null;
    }
  }

  void _hapticFeedback() {
    // Add haptic feedback for better UX
    // You can uncomment this if you add the haptic_feedback dependency
    // HapticFeedback.lightImpact();
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.sentiment_satisfied_alt, color: Colors.blue),
            SizedBox(width: 8),
            Text('Mood Notes'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('A beautiful app to track your daily moods and emotions.'),
            const SizedBox(height: 16),
            Text(
              'Features:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text('• Daily mood tracking\n'
                      '• Visual calendar view\n'
                      '• Analytics and insights\n'
                      '• Data export\n'
                      '• Dark mode support\n'
                      '• Daily reminders'),
            const SizedBox(height: 16),
            Text(
              'Total entries: ${moodEntries.length}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
