import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/main_navigation_page.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';
import 'services/encryption_service.dart';
import 'services/crash_reporting_service.dart';
import 'services/connectivity_service.dart';
import 'services/mood_database_storage.dart';
import 'services/performance_service.dart';
import 'viewmodels/view_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    
    // Initialize services in order
    await PerformanceService.initialize();
    await EncryptionService.initialize();
    await CrashReportingService.initialize();
    await MoodDatabaseStorage.initialize();
    
    final connectivityService = ConnectivityService();
    await connectivityService.initialize();
    
    final themeService = ThemeService();
    await themeService.loadTheme();
    
    final notificationService = NotificationService();
    await notificationService.initialize();
    
    // End app launch timing
    await PerformanceService.endTimer('app_launch');
    
    runApp(MoodNoteApp(
      themeService: themeService,
      connectivityService: connectivityService,
    ));
  } catch (error, stackTrace) {
    // Report initialization errors
    await CrashReportingService.reportError(
      error,
      stackTrace,
      context: 'App initialization failed',
    );
    
    // Run app with minimal functionality in case of initialization failure
    runApp(const MoodNoteApp());
  }
}

class MoodNoteApp extends StatelessWidget {
  final ThemeService? themeService;
  final ConnectivityService? connectivityService;
  
  const MoodNoteApp({
    super.key,
    this.themeService,
    this.connectivityService,
  });

  @override
  Widget build(BuildContext context) {
    final providers = <ChangeNotifierProvider>[
      if (themeService != null)
        ChangeNotifierProvider.value(value: themeService!),
      if (connectivityService != null)
        ChangeNotifierProvider.value(value: connectivityService!),
      ChangeNotifierProvider(create: (_) => MoodViewModel()),
      ChangeNotifierProvider(create: (_) => CalendarViewModel()),
      ChangeNotifierProvider(create: (_) => AnalyticsViewModel()),
    ];

    // Add NavigationViewModel with dependency on MoodViewModel
    return MultiProvider(
      providers: [
        ...providers,
        ChangeNotifierProxyProvider<MoodViewModel, NavigationViewModel>(
          create: (context) => NavigationViewModel(
            Provider.of<MoodViewModel>(context, listen: false),
          ),
          update: (context, moodViewModel, previous) =>
              NavigationViewModel(moodViewModel),
        ),
      ],
      child: MaterialApp(
        title: 'Mood Tracker',
        themeMode: ThemeMode.dark, // Always use dark mode for Web3 style
        theme: themeService?.darkTheme ?? ThemeService.darkTheme,
        darkTheme: themeService?.darkTheme ?? ThemeService.darkTheme,
        home: const MainNavigationPage(),
        navigatorObservers: [
          // Add Firebase Analytics observer for screen tracking
          if (connectivityService != null)
            AnalyticsNavigatorObserver(),
        ],
      ),
    );
  }
}

/// Custom navigator observer for analytics
class AnalyticsNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      CrashReportingService.logScreenView(route.settings.name!);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute?.settings.name != null) {
      CrashReportingService.logScreenView(previousRoute!.settings.name!);
    }
  }
}
