import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../services/theme_service.dart';
import '../services/notification_service.dart';
import '../services/export_service.dart';
import '../models/mood_entry.dart';
import '../utils/animations.dart';

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
    setState(() {
      _remindersEnabled = false;
    });
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
            'Settings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SlideTransitionAnimation(
              delay: const Duration(milliseconds: 200),
              child: _buildSection(
                title: 'Theme',
                icon: Icons.palette_outlined,
                gradient: ThemeService.primaryGradient,
                child: _buildThemeSection(),
              ),
            ),
            const SizedBox(height: 16),
            SlideTransitionAnimation(
              delay: const Duration(milliseconds: 400),
              child: _buildSection(
                title: 'Notifications',
                icon: Icons.notifications_outlined,
                gradient: ThemeService.secondaryGradient,
                child: _buildNotificationSection(),
              ),
            ),
            const SizedBox(height: 16),
            SlideTransitionAnimation(
              delay: const Duration(milliseconds: 600),
              child: _buildSection(
                title: 'Data Management',
                icon: Icons.save_outlined,
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: _buildDataSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Gradient gradient,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSection() {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return Column(
          children: [
            ListTile(
              title: const Text(
                'Dark Mode',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Enable dark theme',
                style: TextStyle(color: Colors.white70),
              ),
              trailing: Switch(
                value: themeService.isDarkMode,
                onChanged: (value) async {
                  await themeService.setThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationSection() {
    return Column(
      children: [
        ListTile(
          title: const Text(
            'Daily Reminders',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            'Get reminded to log your mood',
            style: TextStyle(color: Colors.white70),
          ),
          trailing: Switch(
            value: _remindersEnabled,
            onChanged: (value) async {
              if (value) {
                final granted = await _notificationService.requestPermission();
                if (!granted) {
                  return;
                }
              }
              setState(() => _remindersEnabled = value);
              if (value) {
                await _notificationService.scheduleDailyNotification(_reminderTime);
              } else {
                await _notificationService.cancelAllNotifications();
              }
            },
            activeColor: Theme.of(context).primaryColor,
          ),
        ),
        if (_remindersEnabled) ...[
          ListTile(
            title: const Text(
              'Reminder Time',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              _reminderTime.format(context),
              style: TextStyle(color: Colors.white70),
            ),
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: _reminderTime,
              );
              if (picked != null && picked != _reminderTime) {
                setState(() => _reminderTime = picked);
                await _notificationService.scheduleDailyNotification(picked);
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDataSection() {
    return Column(
      children: [
        ListTile(
          title: const Text(
            'Export Data',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            'Save your mood data as CSV',
            style: TextStyle(color: Colors.white70),
          ),
          trailing: Container(
            decoration: BoxDecoration(
              gradient: ThemeService.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => ExportService.exportToCSV(widget.moodEntries),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Export',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        ListTile(
          title: const Text(
            'Privacy Policy',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            'Read our privacy policy',
            style: TextStyle(color: Colors.white70),
          ),
          onTap: () {
            // TODO: Add privacy policy
          },
        ),
      ],
    );
  }
}
