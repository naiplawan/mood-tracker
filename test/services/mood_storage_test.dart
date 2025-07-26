import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_notes_app/services/mood_storage.dart';
import 'package:mood_notes_app/models/mood_entry.dart';

void main() {
  group('MoodStorage', () {
    setUp(() {
      // Initialize SharedPreferences with fake data
      SharedPreferences.setMockInitialValues({});
    });

    test('should save and load mood entries', () async {
      // Arrange
      final entries = [
        MoodEntry(
          id: '1',
          mood: 'Happy',
          emoji: '😊',
          note: 'Great day!',
          timestamp: DateTime.now(),
        ),
        MoodEntry(
          id: '2',
          mood: 'Sad',
          emoji: '😢',
          note: 'Feeling down',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];

      // Act
      await MoodStorage.saveMoodEntries(entries);
      final loadedEntries = await MoodStorage.loadMoodEntries();

      // Assert
      expect(loadedEntries.length, 2);
      expect(loadedEntries[0].id, '1'); // Should be sorted by timestamp (newest first)
      expect(loadedEntries[1].id, '2');
      expect(loadedEntries[0].mood, 'Happy');
      expect(loadedEntries[1].mood, 'Sad');
    });

    test('should return empty list when no data exists', () async {
      // Act
      final entries = await MoodStorage.loadMoodEntries();

      // Assert
      expect(entries, isEmpty);
    });

    test('should maintain chronological order (newest first)', () async {
      // Arrange
      final now = DateTime.now();
      final entries = [
        MoodEntry(
          id: '1',
          mood: 'Happy',
          emoji: '😊',
          note: 'Old entry',
          timestamp: now.subtract(const Duration(days: 2)),
        ),
        MoodEntry(
          id: '2',
          mood: 'Neutral',
          emoji: '😐',
          note: 'Recent entry',
          timestamp: now,
        ),
        MoodEntry(
          id: '3',
          mood: 'Sad',
          emoji: '😢',
          note: 'Middle entry',
          timestamp: now.subtract(const Duration(days: 1)),
        ),
      ];

      // Act
      await MoodStorage.saveMoodEntries(entries);
      final loadedEntries = await MoodStorage.loadMoodEntries();

      // Assert
      expect(loadedEntries[0].id, '2'); // Most recent
      expect(loadedEntries[1].id, '3'); // Middle
      expect(loadedEntries[2].id, '1'); // Oldest
    });
  });
}