import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../services/notification_service.dart';
import '../services/export_service.dart';
import '../models/mood_entry.dart';

class SettingsPage extends StatefulWidget {
  final List<MoodEntry> moodEntries;

  const SettingsPage({super.key, required this.moodEntries});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _remindersEnabled = false;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  Future<void> _loadSettings() async {
    // For now, we'll assume reminders are disabled by default
    // In a real app, you'd want to store this preference
    setState(() {
      _remindersEnabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: ListView(
        children: [
          _buildThemeSection(),
          const Divider(),
          _buildNotificationSection(),
          const Divider(),
          _buildDataSection(),
          const Divider(),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildThemeSection() {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Appearance',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light Theme'),
              subtitle: const Text('Use light colors'),
              value: ThemeMode.light,
              groupValue: themeService.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeService.setThemeMode(value);
                }
              },
              secondary: const Icon(Icons.light_mode),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark Theme'),
              subtitle: const Text('Use dark colors'),
              value: ThemeMode.dark,
              groupValue: themeService.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeService.setThemeMode(value);
                }
              },
              secondary: const Icon(Icons.dark_mode),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System Theme'),
              subtitle: const Text('Follow system settings'),
              value: ThemeMode.system,
              groupValue: themeService.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeService.setThemeMode(value);
                }
              },
              secondary: const Icon(Icons.auto_mode),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Notifications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Daily Reminders'),
          subtitle: const Text('Get reminded to log your mood'),
          value: _remindersEnabled,
          onChanged: (bool value) {
            setState(() {
              _remindersEnabled = value;
            });
            _toggleReminders(value);
          },
          secondary: const Icon(Icons.notifications),
        ),
        if (_remindersEnabled)
          ListTile(
            title: const Text('Reminder Time'),
            subtitle: Text('Daily reminder at ${_reminderTime.format(context)}'),
            trailing: const Icon(Icons.access_time),
            onTap: _selectReminderTime,
          ),
      ],
    );
  }

  Widget _buildDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Data Management',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ListTile(
          title: const Text('Export Data'),
          subtitle: const Text('Export your mood data to CSV'),
          leading: const Icon(Icons.file_download),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _exportData(context),
        ),
        ListTile(
          title: const Text('Export Summary'),
          subtitle: const Text('Export a detailed summary report'),
          leading: const Icon(Icons.summarize),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _exportSummary(context),
        ),
        ListTile(
          title: Text(
            'Clear All Data',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          subtitle: const Text('Permanently delete all mood entries'),
          leading: Icon(
            Icons.delete_forever,
            color: Theme.of(context).colorScheme.error,
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _showClearDataDialog,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'About',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const ListTile(
          title: Text('Version'),
          subtitle: Text('1.0.0'),
          leading: Icon(Icons.info),
        ),
        const ListTile(
          title: Text('Developer'),
          subtitle: Text('Your Name'),
          leading: Icon(Icons.person),
        ),
        ListTile(
          title: const Text('Privacy Policy'),
          leading: const Icon(Icons.privacy_tip),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            _showPrivacyDialog();
          },
        ),
      ],
    );
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
      
      if (_remindersEnabled) {
        // Reschedule with new time
        await _notificationService.cancelNotification(0);
        await _notificationService.scheduleDailyReminder(
          id: 0,
          title: '💭 Time for a mood check!',
          body: 'How are you feeling today? Take a moment to log your mood.',
          hour: _reminderTime.hour,
          minute: _reminderTime.minute,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reminder time updated to ${_reminderTime.format(context)}'),
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleReminders(bool enabled) async {
    if (enabled) {
      await _notificationService.scheduleDailyReminder(
        id: 0,
        title: '💭 Time for a mood check!',
        body: 'How are you feeling today? Take a moment to log your mood.',
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily reminders enabled'),
          ),
        );
      }
    } else {
      await _notificationService.cancelNotification(0);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily reminders disabled'),
          ),
        );
      }
    }
  }

  Future<void> _exportData(BuildContext context) async {
    if (widget.moodEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No data to export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await ExportService.shareData(widget.moodEntries, context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportSummary(BuildContext context) async {
    if (widget.moodEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No data to export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final result = await ExportService.exportSummaryReport(widget.moodEntries);
      if (result['success'] && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Summary Exported'),
              ],
            ),
            content: Text('Summary report saved to Documents folder.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Clear All Data'),
          ],
        ),
        content: const Text(
          'This will permanently delete all your mood entries. This action cannot be undone.\n\nAre you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // This would need to be implemented in the parent widget
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Clear data functionality needs to be implemented'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Mood Notes Privacy Policy\n\n'
            '1. Data Storage: All your mood data is stored locally on your device. We do not collect or store any personal information on external servers.\n\n'
            '2. Data Usage: Your mood entries are used solely for providing you with insights and analytics within the app.\n\n'
            '3. Data Sharing: We do not share your data with any third parties. Your privacy is our priority.\n\n'
            '4. Data Export: You can export your data at any time through the settings page.\n\n'
            '5. Data Deletion: You can delete all your data at any time through the settings page.\n\n'
            'For any questions about this privacy policy, please contact us.',
          ),
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
