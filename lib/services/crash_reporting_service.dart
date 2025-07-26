import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Service for crash reporting and analytics
class CrashReportingService {
  static FirebaseCrashlytics? _crashlytics;
  static FirebaseAnalytics? _analytics;

  /// Initialize crash reporting and analytics
  static Future<void> initialize() async {
    if (kIsWeb) {
      // Firebase Crashlytics doesn't support web yet
      return;
    }

    try {
      _crashlytics = FirebaseCrashlytics.instance;
      _analytics = FirebaseAnalytics.instance;

      // Enable crash collection in release mode
      if (kReleaseMode) {
        await _crashlytics?.setCrashlyticsCollectionEnabled(true);
      }

      // Set up global error handling
      FlutterError.onError = (FlutterErrorDetails details) {
        _crashlytics?.recordFlutterFatalError(details);
      };

      // Handle async errors
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics?.recordError(error, stack, fatal: true);
        return true;
      };

      print('Crash reporting service initialized successfully');
    } catch (e) {
      print('Error initializing crash reporting service: $e');
    }
  }

  /// Report a non-fatal error
  static Future<void> reportError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) async {
    if (_crashlytics == null) return;

    try {
      // Set custom context if provided
      if (context != null) {
        await _crashlytics!.setCustomKey('error_context', context);
      }

      // Set additional data
      if (additionalData != null) {
        for (final entry in additionalData.entries) {
          await _crashlytics!.setCustomKey(entry.key, entry.value);
        }
      }

      await _crashlytics!.recordError(
        error,
        stackTrace,
        fatal: false,
      );
    } catch (e) {
      print('Error reporting crash: $e');
    }
  }

  /// Set user identifier for crash reports
  static Future<void> setUserId(String userId) async {
    if (_crashlytics == null) return;

    try {
      await _crashlytics!.setUserIdentifier(userId);
      await _analytics?.setUserId(id: userId);
    } catch (e) {
      print('Error setting user ID: $e');
    }
  }

  /// Set custom key-value pairs for crash context
  static Future<void> setCustomKey(String key, dynamic value) async {
    if (_crashlytics == null) return;

    try {
      await _crashlytics!.setCustomKey(key, value);
    } catch (e) {
      print('Error setting custom key: $e');
    }
  }

  /// Log custom events for analytics
  static Future<void> logEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    if (_analytics == null) return;

    try {
      await _analytics!.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      print('Error logging event: $e');
    }
  }

  /// Log mood entry creation
  static Future<void> logMoodEntryCreated(String mood) async {
    await logEvent('mood_entry_created', parameters: {
      'mood': mood,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Log mood entry deletion
  static Future<void> logMoodEntryDeleted() async {
    await logEvent('mood_entry_deleted', parameters: {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Log export functionality usage
  static Future<void> logDataExport(String format) async {
    await logEvent('data_export', parameters: {
      'format': format,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Log notification settings changes
  static Future<void> logNotificationToggle(bool enabled) async {
    await logEvent('notification_settings_changed', parameters: {
      'enabled': enabled,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Log screen view
  static Future<void> logScreenView(String screenName) async {
    if (_analytics == null) return;

    try {
      await _analytics!.logScreenView(screenName: screenName);
    } catch (e) {
      print('Error logging screen view: $e');
    }
  }

  /// Log app performance metrics
  static Future<void> logPerformanceMetric(
    String metricName,
    int valueInMs,
  ) async {
    await logEvent('performance_metric', parameters: {
      'metric_name': metricName,
      'value_ms': valueInMs,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Force a crash (for testing purposes only)
  static void forceCrash() {
    if (kDebugMode && _crashlytics != null) {
      _crashlytics!.crash();
    }
  }

  /// Test crash reporting
  static Future<void> testCrashReporting() async {
    if (kDebugMode) {
      await reportError(
        'Test crash report',
        StackTrace.current,
        context: 'Testing crash reporting functionality',
        additionalData: {'test': true},
      );
    }
  }
}