import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mood_notes_app/viewmodels/mood_view_model.dart';
import 'package:mood_notes_app/models/mood_entry.dart';
import 'package:mood_notes_app/services/mood_storage.dart';

// Generate mocks using build_runner
@GenerateMocks([MoodStorage])
import 'mood_view_model_test.mocks.dart';

void main() {
  group('MoodViewModel', () {
    late MoodViewModel viewModel;
    
    setUp(() {
      viewModel = MoodViewModel();
    });

    test('should start with empty mood entries', () {
      expect(viewModel.moodEntries, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
    });

    test('should add mood entry successfully', () async {
      // Arrange
      final entry = MoodEntry(
        id: 'test-id',
        mood: 'Happy',
        emoji: '😊',
        note: 'Test note',
        timestamp: DateTime.now(),
      );

      // Act
      await viewModel.addMoodEntry(entry);

      // Assert
      expect(viewModel.moodEntries.length, 1);
      expect(viewModel.moodEntries.first.id, 'test-id');
      expect(viewModel.errorMessage, null);
    });

    test('should delete mood entry successfully', () async {
      // Arrange
      final entry1 = MoodEntry(
        id: 'test-id-1',
        mood: 'Happy',
        emoji: '😊',
        note: 'Test note 1',
        timestamp: DateTime.now(),
      );
      final entry2 = MoodEntry(
        id: 'test-id-2',
        mood: 'Sad',
        emoji: '😢',
        note: 'Test note 2',
        timestamp: DateTime.now(),
      );

      await viewModel.addMoodEntry(entry1);
      await viewModel.addMoodEntry(entry2);

      // Act
      await viewModel.deleteMoodEntry(entry1);

      // Assert
      expect(viewModel.moodEntries.length, 1);
      expect(viewModel.moodEntries.first.id, 'test-id-2');
    });

    test('should update mood entry successfully', () async {
      // Arrange
      final originalEntry = MoodEntry(
        id: 'test-id',
        mood: 'Happy',
        emoji: '😊',
        note: 'Original note',
        timestamp: DateTime.now(),
      );
      
      final updatedEntry = MoodEntry(
        id: 'test-id',
        mood: 'Excited',
        emoji: '🤩',
        note: 'Updated note',
        timestamp: originalEntry.timestamp,
      );

      await viewModel.addMoodEntry(originalEntry);

      // Act
      await viewModel.updateMoodEntry(updatedEntry);

      // Assert
      expect(viewModel.moodEntries.length, 1);
      expect(viewModel.moodEntries.first.mood, 'Excited');
      expect(viewModel.moodEntries.first.note, 'Updated note');
    });

    test('should get mood entries for specific date', () async {
      // Arrange
      final targetDate = DateTime(2024, 1, 15);
      final entry1 = MoodEntry(
        id: '1',
        mood: 'Happy',
        emoji: '😊',
        note: 'Same day',
        timestamp: DateTime(2024, 1, 15, 10, 0),
      );
      final entry2 = MoodEntry(
        id: '2',
        mood: 'Sad',
        emoji: '😢',
        note: 'Different day',
        timestamp: DateTime(2024, 1, 16, 10, 0),
      );

      await viewModel.addMoodEntry(entry1);
      await viewModel.addMoodEntry(entry2);

      // Act
      final entriesForDate = viewModel.getMoodEntriesForDate(targetDate);

      // Assert
      expect(entriesForDate.length, 1);
      expect(entriesForDate.first.id, '1');
    });

    test('should get mood statistics', () async {
      // Arrange
      final entries = [
        MoodEntry(id: '1', mood: 'Happy', emoji: '😊', note: '', timestamp: DateTime.now()),
        MoodEntry(id: '2', mood: 'Happy', emoji: '😊', note: '', timestamp: DateTime.now()),
        MoodEntry(id: '3', mood: 'Sad', emoji: '😢', note: '', timestamp: DateTime.now()),
      ];

      for (final entry in entries) {
        await viewModel.addMoodEntry(entry);
      }

      // Act
      final stats = viewModel.getMoodStatistics();

      // Assert
      expect(stats['Happy'], 2);
      expect(stats['Sad'], 1);
    });

    test('should get mood entries for last N days', () async {
      // Arrange
      final now = DateTime.now();
      final entries = [
        MoodEntry(id: '1', mood: 'Happy', emoji: '😊', note: '', timestamp: now),
        MoodEntry(id: '2', mood: 'Sad', emoji: '😢', note: '', timestamp: now.subtract(const Duration(days: 2))),
        MoodEntry(id: '3', mood: 'Neutral', emoji: '😐', note: '', timestamp: now.subtract(const Duration(days: 5))),
      ];

      for (final entry in entries) {
        await viewModel.addMoodEntry(entry);
      }

      // Act
      final recentEntries = viewModel.getMoodEntriesForLastDays(3);

      // Assert
      expect(recentEntries.length, 2); // Only entries within last 3 days
      expect(recentEntries.map((e) => e.id), containsAll(['1', '2']));
    });

    test('should clear all entries', () async {
      // Arrange
      final entry = MoodEntry(
        id: 'test-id',
        mood: 'Happy',
        emoji: '😊',
        note: 'Test note',
        timestamp: DateTime.now(),
      );
      await viewModel.addMoodEntry(entry);

      // Act
      await viewModel.clearAllEntries();

      // Assert
      expect(viewModel.moodEntries, isEmpty);
    });
  });
}