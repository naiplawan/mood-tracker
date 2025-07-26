import 'package:flutter/material.dart';
import '../services/crash_reporting_service.dart';
import '../services/connectivity_service.dart';

/// Base view model class that provides common functionality
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOffline = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isOffline => _isOffline;

  /// Set loading state
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Set error message
  void setError(String? error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    setError(null);
  }

  /// Set offline state
  void setOffline(bool offline) {
    if (_isOffline != offline) {
      _isOffline = offline;
      notifyListeners();
    }
  }

  /// Handle async operations with loading, error states, and crash reporting
  Future<T?> handleAsync<T>(
    Future<T> Function() operation, {
    String? context,
    bool reportErrors = true,
    T? fallbackValue,
  }) async {
    try {
      setLoading(true);
      clearError();
      
      // Check connectivity
      final connectivityService = ConnectivityService();
      setOffline(!connectivityService.isConnected);
      
      final result = await operation();
      return result;
    } catch (e, stackTrace) {
      final errorMessage = _getErrorMessage(e);
      setError(errorMessage);
      
      // Report error to crash reporting service
      if (reportErrors) {
        await CrashReportingService.reportError(
          e,
          stackTrace,
          context: context ?? 'ViewModel operation failed',
          additionalData: {
            'viewModel': runtimeType.toString(),
            'isOffline': _isOffline,
          },
        );
      }
      
      return fallbackValue;
    } finally {
      setLoading(false);
    }
  }

  /// Handle async operations with retry logic
  Future<T?> handleAsyncWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    String? context,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await handleAsync(
          operation,
          context: context,
          reportErrors: attempts == maxRetries - 1, // Only report on final failure
        );
      } catch (e) {
        attempts++;
        if (attempts < maxRetries) {
          await Future.delayed(retryDelay);
        } else {
          rethrow;
        }
      }
    }
    
    return null;
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      final errorString = error.toString();
      
      // Handle common error types
      if (errorString.contains('SocketException') || 
          errorString.contains('network')) {
        return 'Network connection error. Please check your internet connection.';
      } else if (errorString.contains('TimeoutException')) {
        return 'Operation timed out. Please try again.';
      } else if (errorString.contains('FormatException')) {
        return 'Data format error. Please try again.';
      } else if (errorString.contains('Data integrity check failed')) {
        return 'Data corruption detected. Your data may have been tampered with.';
      }
    }
    
    // Return a generic error message for unknown errors
    return 'An unexpected error occurred. Please try again.';
  }

  /// Retry the last failed operation
  Future<void> retry() async {
    // Subclasses can override this to implement retry logic
    clearError();
  }

  /// Handle offline mode gracefully
  void handleOfflineMode() {
    setError('You are currently offline. Some features may not be available.');
  }
}
