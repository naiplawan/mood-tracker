import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/performance_service.dart';

/// Utility functions for performance optimization
class PerformanceUtils {
  /// Debounce function calls to prevent excessive execution
  static Timer? _debounceTimer;
  
  static void debounce(Duration duration, VoidCallback callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, callback);
  }

  /// Throttle function calls to limit execution frequency
  static DateTime? _lastThrottleTime;
  
  static void throttle(Duration duration, VoidCallback callback) {
    final now = DateTime.now();
    if (_lastThrottleTime == null || 
        now.difference(_lastThrottleTime!) >= duration) {
      _lastThrottleTime = now;
      callback();
    }
  }

  /// Batch multiple operations together
  static Timer? _batchTimer;
  static final List<VoidCallback> _batchedOperations = [];
  
  static void batch(VoidCallback operation, {Duration delay = const Duration(milliseconds: 16)}) {
    _batchedOperations.add(operation);
    
    _batchTimer?.cancel();
    _batchTimer = Timer(delay, () {
      for (final op in _batchedOperations) {
        op();
      }
      _batchedOperations.clear();
    });
  }

  /// Optimize image loading with caching
  static Widget optimizedImage(
    String imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? const CircularProgressIndicator();
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? const Icon(Icons.error);
      },
      // Enable caching
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
    );
  }

  /// Create a performance-monitored Future
  static Future<T> monitoredFuture<T>(
    String operationName,
    Future<T> Function() operation,
  ) {
    return PerformanceService.measureAsync(operationName, operation);
  }

  /// Create a performance-monitored function
  static T monitoredOperation<T>(
    String operationName,
    T Function() operation,
  ) {
    return PerformanceService.measureSync(operationName, operation);
  }

  /// Lazy loading utility for expensive computations
  static Lazy<T> lazy<T>(T Function() computation) {
    return Lazy(computation);
  }

  /// Memory-efficient list builder
  static Widget efficientListView<T>({
    required List<T> items,
    required Widget Function(BuildContext, T, int) itemBuilder,
    ScrollController? controller,
    bool shrinkWrap = false,
    EdgeInsets? padding,
    double? itemExtent,
  }) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemExtent: itemExtent, // Improves performance when items have fixed height
      itemCount: items.length,
      cacheExtent: 1000, // Cache more items for smoother scrolling
      itemBuilder: (context, index) {
        final item = items[index];
        return itemBuilder(context, item, index);
      },
    );
  }

  /// Optimized grid view
  static Widget efficientGridView<T>({
    required List<T> items,
    required Widget Function(BuildContext, T, int) itemBuilder,
    required int crossAxisCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
    ScrollController? controller,
    EdgeInsets? padding,
  }) {
    return GridView.builder(
      controller: controller,
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      cacheExtent: 1000,
      itemBuilder: (context, index) {
        final item = items[index];
        return itemBuilder(context, item, index);
      },
    );
  }

  /// Create a memoized function to cache expensive computations
  static Memoizer<T> memoize<T>(T Function() computation) {
    return Memoizer(computation);
  }

  /// Optimize widget rebuilds with const constructors
  static Widget constantWidget(Widget child) {
    // This is a wrapper to encourage const usage
    return child;
  }

  /// Profile widget build times in debug mode
  static Widget profiledWidget(String widgetName, Widget child) {
    if (kDebugMode) {
      return _ProfiledWidget(widgetName: widgetName, child: child);
    }
    return child;
  }

  /// Optimize list updates with proper keys
  static Key optimizedKey(String id) {
    return ValueKey(id);
  }

  /// Batch state updates to minimize rebuilds
  static void batchStateUpdates(List<VoidCallback> updates) {
    // Execute all updates in the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final update in updates) {
        update();
      }
    });
  }

  /// Preload critical resources
  static Future<void> preloadResources(List<Future<void>> resources) async {
    await Future.wait(resources, eagerError: false);
  }

  /// Optimize text rendering for long texts
  static Widget optimizedText(
    String text, {
    TextStyle? style,
    int? maxLines,
    TextOverflow? overflow,
    bool softWrap = true,
  }) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
      softWrap: softWrap,
      // Optimize text rendering
      textWidthBasis: TextWidthBasis.longestLine,
    );
  }
}

/// Lazy loading utility class
class Lazy<T> {
  final T Function() _computation;
  T? _value;
  bool _hasValue = false;

  Lazy(this._computation);

  T get value {
    if (!_hasValue) {
      _value = _computation();
      _hasValue = true;
    }
    return _value!;
  }

  bool get isComputed => _hasValue;

  void reset() {
    _value = null;
    _hasValue = false;
  }
}

/// Memoization utility class
class Memoizer<T> {
  final T Function() _computation;
  T? _cachedValue;
  bool _hasValue = false;

  Memoizer(this._computation);

  T call() {
    if (!_hasValue) {
      _cachedValue = _computation();
      _hasValue = true;
    }
    return _cachedValue!;
  }

  void invalidate() {
    _cachedValue = null;
    _hasValue = false;
  }
}

/// Widget wrapper for profiling build times
class _ProfiledWidget extends StatelessWidget {
  final String widgetName;
  final Widget child;

  const _ProfiledWidget({
    required this.widgetName,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final stopwatch = Stopwatch()..start();
    final result = child;
    stopwatch.stop();
    
    PerformanceService.trackWidgetBuild(widgetName, stopwatch.elapsed);
    return result;
  }
}

/// Performance-optimized state mixin
mixin PerformanceOptimizedState<T extends StatefulWidget> on State<T> {
  late final String _widgetName = T.toString();

  @override
  Widget build(BuildContext context) {
    final stopwatch = Stopwatch()..start();
    final widget = buildOptimized(context);
    stopwatch.stop();
    
    PerformanceService.trackWidgetBuild(_widgetName, stopwatch.elapsed);
    return widget;
  }

  /// Override this method instead of build()
  Widget buildOptimized(BuildContext context);

  /// Debounced setState to prevent excessive rebuilds
  void setStateDebounced(VoidCallback fn, {Duration delay = const Duration(milliseconds: 16)}) {
    PerformanceUtils.debounce(delay, () => setState(fn));
  }

  /// Throttled setState to limit rebuild frequency
  void setStateThrottled(VoidCallback fn, {Duration interval = const Duration(milliseconds: 100)}) {
    PerformanceUtils.throttle(interval, () => setState(fn));
  }
}