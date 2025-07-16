import '../models/mood_entry.dart';
import 'base_view_model.dart';

/// ViewModel for the Analytics page
class AnalyticsViewModel extends BaseViewModel {
  List<MoodEntry> _moodEntries = [];

  List<MoodEntry> get moodEntries => _moodEntries;

  /// Initialize the analytics view model
  void initialize(List<MoodEntry> moodEntries) {
    _moodEntries = moodEntries;
    notifyListeners();
  }

  /// Update mood entries
  void updateMoodEntries(List<MoodEntry> moodEntries) {
    _moodEntries = moodEntries;
    notifyListeners();
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

  /// Get mood trend data for the last 7 days
  Map<DateTime, List<MoodEntry>> getWeeklyTrend() {
    final weeklyData = <DateTime, List<MoodEntry>>{};
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      weeklyData[date] = _moodEntries.where((entry) {
        final entryDate = DateTime(
          entry.timestamp.year,
          entry.timestamp.month,
          entry.timestamp.day,
        );
        return entryDate.isAtSameMomentAs(date);
      }).toList();
    }
    
    return weeklyData;
  }

  /// Get most frequent mood
  String? getMostFrequentMood() {
    final stats = getMoodStatistics();
    if (stats.isEmpty) return null;
    
    return stats.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get average mood entries per day
  double getAverageMoodEntriesPerDay() {
    if (_moodEntries.isEmpty) return 0.0;
    
    final oldestEntry = _moodEntries.last.timestamp;
    final daysDifference = DateTime.now().difference(oldestEntry).inDays + 1;
    
    return _moodEntries.length / daysDifference;
  }

  /// Get mood streak (consecutive days with mood entries)
  int getCurrentMoodStreak() {
    if (_moodEntries.isEmpty) return 0;
    
    final now = DateTime.now();
    int streak = 0;
    
    for (int i = 0; i < 365; i++) { // Check last year max
      final checkDate = DateTime(now.year, now.month, now.day - i);
      final hasEntry = _moodEntries.any((entry) {
        final entryDate = DateTime(
          entry.timestamp.year,
          entry.timestamp.month,
          entry.timestamp.day,
        );
        return entryDate.isAtSameMomentAs(checkDate);
      });
      
      if (hasEntry) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  /// Get mood distribution for a specific time period
  Map<String, double> getMoodDistribution({int? lastDays}) {
    List<MoodEntry> entries = _moodEntries;
    
    if (lastDays != null) {
      entries = getMoodEntriesForLastDays(lastDays);
    }
    
    if (entries.isEmpty) return {};
    
    final stats = <String, int>{};
    for (final entry in entries) {
      stats[entry.mood] = (stats[entry.mood] ?? 0) + 1;
    }
    
    final total = entries.length;
    return stats.map((mood, count) => 
      MapEntry(mood, (count / total) * 100));
  }
}
