import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_navigation_page.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';
import 'viewmodels/view_models.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider(create: (_) => MoodViewModel()),
        ChangeNotifierProxyProvider<MoodViewModel, NavigationViewModel>(
          create: (context) => NavigationViewModel(
            Provider.of<MoodViewModel>(context, listen: false),
          ),
          update: (context, moodViewModel, previous) =>
              NavigationViewModel(moodViewModel),
        ),
        ChangeNotifierProvider(create: (_) => CalendarViewModel()),
        ChangeNotifierProvider(create: (_) => AnalyticsViewModel()),
      ],
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
