import '../models/mood_entry.dart';
import '../services/mood_storage.dart';
import '../services/crash_reporting_service.dart';
import 'base_view_model.dart';

/// Main ViewModel for managing mood entries across the application
class MoodViewModel extends BaseViewModel {
  List<MoodEntry> _moodEntries = [];
  List<MoodEntry> _pendingEntries = []; // For offline support
  
  List<MoodEntry> get moodEntries => List.unmodifiable(_moodEntries);
  List<MoodEntry> get pendingEntries => List.unmodifiable(_pendingEntries);
  bool get hasPendingEntries => _pendingEntries.isNotEmpty;
  
  /// Get mood entries for a specific date
  List<MoodEntry> getMoodEntriesForDate(DateTime date) {
    return _moodEntries.where((entry) {
      return entry.timestamp.year == date.year &&
             entry.timestamp.month == date.month &&
             entry.timestamp.day == date.day;
    }).toList();
  }

  /// Load mood entries from storage
  Future<void> loadMoodEntries() async {
    await handleAsyncWithRetry(
      () async {
        final entries = await MoodStorage.loadMoodEntries();
        _moodEntries = entries;
        notifyListeners();
        
        // Log successful data load
        await CrashReportingService.logEvent('mood_entries_loaded', parameters: {
          'count': entries.length,
        });
      },
      context: 'Loading mood entries from storage',
    );
  }

  /// Add a new mood entry
  Future<void> addMoodEntry(MoodEntry entry) async {
    if (isOffline) {
      // Store in pending entries for offline support
      _pendingEntries.add(entry);
      notifyListeners();
      return;
    }

    await handleAsync(
      () async {
        _moodEntries.add(entry);
        _moodEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        await MoodStorage.saveMoodEntries(_moodEntries);
        notifyListeners();
        
        // Log mood entry creation
        await CrashReportingService.logMoodEntryCreated(entry.mood);
      },
      context: 'Adding new mood entry',
      fallbackValue: null,
    );
  }

  /// Delete a mood entry
  Future<void> deleteMoodEntry(MoodEntry entry) async {
    await handleAsync(() async {
      _moodEntries.removeWhere((e) => e.id == entry.id);
      await MoodStorage.saveMoodEntries(_moodEntries);
      notifyListeners();
    });
  }

  /// Update an existing mood entry
  Future<void> updateMoodEntry(MoodEntry updatedEntry) async {
    await handleAsync(() async {
      final index = _moodEntries.indexWhere((e) => e.id == updatedEntry.id);
      if (index != -1) {
        _moodEntries[index] = updatedEntry;
        _moodEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        await MoodStorage.saveMoodEntries(_moodEntries);
        notifyListeners();
      }
    });
  }

  /// Get mood statistics
  Map<String, int> getMoodStatistics() {
    final stats = <String, int>{};
    for (final entry in _moodEntries) {
      stats[entry.mood] = (stats[entry.mood] ?? 0) + 1;
    }
    return stats;
  }

  /// Get mood entries for the last N days
  List<MoodEntry> getMoodEntriesForLastDays(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _moodEntries.where((entry) => 
      entry.timestamp.isAfter(cutoffDate)
    ).toList();
  }

  /// Clear all mood entries
  Future<void> clearAllEntries() async {
    await handleAsync(
      () async {
        _moodEntries.clear();
        _pendingEntries.clear();
        await MoodStorage.saveMoodEntries(_moodEntries);
        notifyListeners();
      },
      context: 'Clearing all mood entries',
    );
  }

  /// Sync pending entries when connection is restored
  Future<void> syncPendingEntries() async {
    if (_pendingEntries.isEmpty || isOffline) return;

    await handleAsync(
      () async {
        // Add pending entries to main list
        _moodEntries.addAll(_pendingEntries);
        _moodEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        // Save to storage
        await MoodStorage.saveMoodEntries(_moodEntries);
        
        // Log sync event
        await CrashReportingService.logEvent('pending_entries_synced', parameters: {
          'count': _pendingEntries.length,
        });
        
        // Clear pending entries
        _pendingEntries.clear();
        notifyListeners();
      },
      context: 'Syncing pending mood entries',
    );
  }

  /// Create backup of all mood entries
  Future<String?> createBackup() async {
    return await handleAsync(
      () async {
        final backup = await MoodStorage.createBackup(_moodEntries);
        
        // Log backup creation
        await CrashReportingService.logEvent('backup_created', parameters: {
          'entries_count': _moodEntries.length,
        });
        
        return backup;
      },
      context: 'Creating mood entries backup',
    );
  }

  /// Restore from backup
  Future<void> restoreFromBackup(String encryptedBackup) async {
    await handleAsync(
      () async {
        final restoredEntries = await MoodStorage.restoreFromBackup(encryptedBackup);
        _moodEntries = restoredEntries;
        await MoodStorage.saveMoodEntries(_moodEntries);
        notifyListeners();
        
        // Log backup restoration
        await CrashReportingService.logEvent('backup_restored', parameters: {
          'entries_count': restoredEntries.length,
        });
      },
      context: 'Restoring mood entries from backup',
    );
  }

  /// Retry last failed operation
  @override
  Future<void> retry() async {
    super.retry();
    
    // Try to sync pending entries if we're back online
    if (!isOffline && _pendingEntries.isNotEmpty) {
      await syncPendingEntries();
    }
    
    // Reload entries
    await loadMoodEntries();
  }

  /// Handle connection status changes
  void onConnectivityChanged(bool isConnected) {
    setOffline(!isConnected);
    
    if (isConnected && _pendingEntries.isNotEmpty) {
      // Auto-sync pending entries when connection is restored
      syncPendingEntries();
    }
  }
}
