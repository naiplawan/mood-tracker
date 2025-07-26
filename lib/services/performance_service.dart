import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'crash_reporting_service.dart';

/// Service for monitoring app performance and reporting metrics
class PerformanceService {
  static final Map<String, Stopwatch> _timers = {};
  static final Map<String, List<int>> _metrics = {};
  static bool _initialized = false;

  /// Initialize performance monitoring
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Set up memory pressure monitoring in debug mode
      if (kDebugMode) {
        _setupMemoryMonitoring();
      }

      // Start app launch time tracking
      startTimer('app_launch');

      _initialized = true;
      developer.log('Performance monitoring initialized', name: 'PerformanceService');
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Performance service initialization failed',
      );
    }
  }

  /// Start timing an operation
  static void startTimer(String operationName) {
    _timers[operationName] = Stopwatch()..start();
  }

  /// End timing an operation and record the result
  static Future<int?> endTimer(String operationName) async {
    final stopwatch = _timers[operationName];
    if (stopwatch == null) {
      developer.log('Timer not found: $operationName', name: 'PerformanceService');
      return null;
    }

    stopwatch.stop();
    final elapsedMs = stopwatch.elapsedMilliseconds;
    
    // Store metric
    _metrics[operationName] ??= [];
    _metrics[operationName]!.add(elapsedMs);

    // Log to console in debug mode
    if (kDebugMode) {
      developer.log('$operationName took ${elapsedMs}ms', name: 'PerformanceService');
    }

    // Report to analytics if operation is slow
    if (elapsedMs > _getSlowThreshold(operationName)) {
      await CrashReportingService.logPerformanceMetric(operationName, elapsedMs);
    }

    // Clean up timer
    _timers.remove(operationName);

    return elapsedMs;
  }

  /// Measure execution time of a function
  static Future<T> measureAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    startTimer(operationName);
    try {
      final result = await operation();
      await endTimer(operationName);
      return result;
    } catch (e) {
      await endTimer(operationName);
      rethrow;
    }
  }

  /// Measure execution time of a synchronous function
  static T measureSync<T>(
    String operationName,
    T Function() operation,
  ) {
    startTimer(operationName);
    try {
      final result = operation();
      endTimer(operationName);
      return result;
    } catch (e) {
      endTimer(operationName);
      rethrow;
    }
  }

  /// Track widget build performance
  static void trackWidgetBuild(String widgetName, Duration buildTime) {
    final elapsedMs = buildTime.inMilliseconds;
    
    _metrics['widget_build_$widgetName'] ??= [];
    _metrics['widget_build_$widgetName']!.add(elapsedMs);

    // Log slow widget builds
    if (elapsedMs > 16) { // 16ms = 60fps threshold
      developer.log(
        'Slow widget build: $widgetName took ${elapsedMs}ms',
        name: 'PerformanceService',
      );
    }
  }

  /// Track memory usage
  static Future<void> trackMemoryUsage(String context) async {
    try {
      // This is a simplified memory tracking
      // In a real app, you might use more sophisticated memory profiling
      final rss = developer.Service.getIsolateMemoryUsage();
      
      developer.log(
        'Memory usage at $context: ${rss?.toString() ?? 'unknown'}',
        name: 'PerformanceService',
      );

      // Log memory usage to analytics periodically
      await CrashReportingService.logEvent('memory_usage', parameters: {
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      developer.log('Failed to track memory usage: $e', name: 'PerformanceService');
    }
  }

  /// Track database operation performance
  static Future<void> trackDatabaseOperation(String operation, int duration) async {
    _metrics['db_$operation'] ??= [];
    _metrics['db_$operation']!.add(duration);

    // Report slow database operations
    if (duration > _getDatabaseSlowThreshold(operation)) {
      await CrashReportingService.logEvent('slow_database_operation', parameters: {
        'operation': operation,
        'duration_ms': duration,
      });
    }
  }

  /// Track network operation performance
  static Future<void> trackNetworkOperation(String operation, int duration, bool success) async {
    _metrics['network_$operation'] ??= [];
    _metrics['network_$operation']!.add(duration);

    await CrashReportingService.logEvent('network_operation', parameters: {
      'operation': operation,
      'duration_ms': duration,
      'success': success,
    });
  }

  /// Get performance statistics
  static Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};

    for (final entry in _metrics.entries) {
      final values = entry.value;
      if (values.isNotEmpty) {
        values.sort();
        stats[entry.key] = {
          'count': values.length,
          'min': values.first,
          'max': values.last,
          'avg': (values.reduce((a, b) => a + b) / values.length).round(),
          'p50': _percentile(values, 0.5),
          'p95': _percentile(values, 0.95),
          'p99': _percentile(values, 0.99),
        };
      }
    }

    return {
      'metrics': stats,
      'active_timers': _timers.keys.toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Report performance summary to analytics
  static Future<void> reportPerformanceSummary() async {
    try {
      final stats = getPerformanceStats();
      
      await CrashReportingService.logEvent('performance_summary', parameters: {
        'metrics_count': _metrics.length,
        'active_timers': _timers.length,
        'summary': stats.toString(),
      });

      // Clear old metrics to prevent memory buildup
      _clearOldMetrics();
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Failed to report performance summary',
      );
    }
  }

  /// Monitor app lifecycle performance
  static Future<void> trackAppLifecycle(String event) async {
    await CrashReportingService.logEvent('app_lifecycle', parameters: {
      'event': event,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Track specific lifecycle events
    switch (event) {
      case 'resumed':
        await trackMemoryUsage('app_resumed');
        break;
      case 'paused':
        await reportPerformanceSummary();
        break;
    }
  }

  /// Monitor frame rendering performance
  static void startFrameMetrics() {
    if (!kReleaseMode) {
      // This would integrate with Flutter's WidgetsBinding frame metrics
      // For production, you might use a more sophisticated approach
      developer.log('Frame metrics monitoring started', name: 'PerformanceService');
    }
  }

  /// Track user interaction performance
  static Future<void> trackUserInteraction(String interaction, int responseTime) async {
    _metrics['interaction_$interaction'] ??= [];
    _metrics['interaction_$interaction']!.add(responseTime);

    // Report slow interactions
    if (responseTime > 500) { // 500ms threshold for user interactions
      await CrashReportingService.logEvent('slow_user_interaction', parameters: {
        'interaction': interaction,
        'response_time_ms': responseTime,
      });
    }
  }

  /// Set up memory monitoring (debug mode only)
  static void _setupMemoryMonitoring() async {
    if (!kDebugMode) return;

    Timer.periodic(const Duration(minutes: 5), (timer) async {
      await trackMemoryUsage('periodic_check');
    });
  }

  /// Get slow operation threshold based on operation type
  static int _getSlowThreshold(String operationName) {
    if (operationName.startsWith('db_')) return 100; // 100ms for database ops
    if (operationName.startsWith('network_')) return 1000; // 1s for network ops
    if (operationName.startsWith('widget_build_')) return 16; // 16ms for 60fps
    if (operationName == 'app_launch') return 3000; // 3s for app launch
    return 500; // 500ms default
  }

  /// Get database slow operation threshold
  static int _getDatabaseSlowThreshold(String operation) {
    switch (operation) {
      case 'insert':
      case 'update':
      case 'delete':
        return 50; // 50ms for write operations
      case 'select':
      case 'query':
        return 100; // 100ms for read operations
      default:
        return 200; // 200ms for complex operations
    }
  }

  /// Calculate percentile from sorted list
  static int _percentile(List<int> sortedValues, double percentile) {
    final index = ((sortedValues.length - 1) * percentile).round();
    return sortedValues[index];
  }

  /// Clear old metrics to prevent memory buildup
  static void _clearOldMetrics() {
    const maxMetricsPerOperation = 1000;
    
    for (final key in _metrics.keys.toList()) {
      final values = _metrics[key]!;
      if (values.length > maxMetricsPerOperation) {
        // Keep only the most recent metrics
        _metrics[key] = values.skip(values.length - maxMetricsPerOperation).toList();
      }
    }
  }

  /// Reset all performance metrics
  static void reset() {
    _timers.clear();
    _metrics.clear();
    developer.log('Performance metrics reset', name: 'PerformanceService');
  }

  /// Check if service is initialized
  static bool get initialized => _initialized;
}