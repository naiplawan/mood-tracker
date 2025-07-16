import '../models/mood_entry.dart';
import '../services/mood_storage.dart';
import 'base_view_model.dart';

/// Main ViewModel for managing mood entries across the application
class MoodViewModel extends BaseViewModel {
  List<MoodEntry> _moodEntries = [];
  
  List<MoodEntry> get moodEntries => List.unmodifiable(_moodEntries);
  
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
    await handleAsync(() async {
      final entries = await MoodStorage.loadMoodEntries();
      _moodEntries = entries;
      notifyListeners();
    });
  }

  /// Add a new mood entry
  Future<void> addMoodEntry(MoodEntry entry) async {
    await handleAsync(() async {
      _moodEntries.add(entry);
      _moodEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      await MoodStorage.saveMoodEntries(_moodEntries);
      notifyListeners();
    });
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
    await handleAsync(() async {
      _moodEntries.clear();
      await MoodStorage.saveMoodEntries(_moodEntries);
      notifyListeners();
    });
  }
}
