import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_navigation_page.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final themeService = ThemeService();
  await themeService.loadTheme();
  
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  runApp(MoodNoteApp(themeService: themeService));
}

class MoodNoteApp extends StatelessWidget {
  final ThemeService themeService;
  
  const MoodNoteApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeService,
      child: MaterialApp(
        title: 'Mood Tracker',
        themeMode: ThemeMode.dark, // Always use dark mode for Web3 style
        theme: ThemeService.darkTheme,
        darkTheme: ThemeService.darkTheme,
        home: const MainNavigationPage(),
      ),
    );
  }
}
