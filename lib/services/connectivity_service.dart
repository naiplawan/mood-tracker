import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Service for monitoring network connectivity
class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity status
    final List<ConnectivityResult> connectivityResults = await _connectivity.checkConnectivity();
    _updateConnectionStatus(connectivityResults);

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
      onError: (error) {
        print('Connectivity monitoring error: $error');
      },
    );
  }

  /// Update connection status based on connectivity results
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final bool wasConnected = _isConnected;
    
    // Check if any connection type is available
    _isConnected = results.any((result) => 
      result != ConnectivityResult.none
    );

    // Notify listeners if status changed
    if (wasConnected != _isConnected) {
      notifyListeners();
      
      // Log connectivity changes
      print('Connectivity changed: ${_isConnected ? 'Connected' : 'Disconnected'}');
    }
  }

  /// Get detailed connectivity information
  Future<Map<String, dynamic>> getConnectivityDetails() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    
    return {
      'isConnected': _isConnected,
      'connectionTypes': results.map((r) => r.name).toList(),
      'hasWifi': results.contains(ConnectivityResult.wifi),
      'hasMobile': results.contains(ConnectivityResult.mobile),
      'hasEthernet': results.contains(ConnectivityResult.ethernet),
    };
  }

  /// Check if specific connection type is available
  Future<bool> hasConnectionType(ConnectivityResult type) async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    return results.contains(type);
  }

  /// Wait for connection to be available
  Future<void> waitForConnection({Duration? timeout}) async {
    if (_isConnected) return;

    final completer = Completer<void>();
    StreamSubscription? subscription;

    subscription = _connectivity.onConnectivityChanged.listen((results) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        subscription?.cancel();
        completer.complete();
      }
    });

    // Set timeout if provided
    if (timeout != null) {
      Timer(timeout, () {
        if (!completer.isCompleted) {
          subscription?.cancel();
          completer.completeError(TimeoutException('Connection timeout', timeout));
        }
      });
    }

    await completer.future;
  }

  /// Dispose of the service
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

/// Exception for connectivity timeouts
class TimeoutException implements Exception {
  final String message;
  final Duration? duration;

  const TimeoutException(this.message, [this.duration]);

  @override
  String toString() => 'TimeoutException: $message';
}