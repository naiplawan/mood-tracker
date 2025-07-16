import 'package:flutter/material.dart';

/// Base view model class that provides common functionality
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

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

  /// Handle async operations with loading and error states
  Future<T?> handleAsync<T>(Future<T> Function() operation) async {
    try {
      setLoading(true);
      clearError();
      final result = await operation();
      return result;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }
}
