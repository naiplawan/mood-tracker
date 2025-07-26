import 'package:flutter_test/flutter_test.dart';
import 'package:mood_notes_app/models/mood_entry.dart';

void main() {
  group('MoodEntry', () {
    test('should create MoodEntry from JSON', () {
      // Arrange
      final json = {
        'id': 'test-id',
        'mood': 'Happy',
        'emoji': '😊',
        'note': 'Test note',
        'timestamp': '2024-01-15T10:30:00.000Z',
      };

      // Act
      final moodEntry = MoodEntry.fromJson(json);

      // Assert
      expect(moodEntry.id, 'test-id');
      expect(moodEntry.mood, 'Happy');
      expect(moodEntry.emoji, '😊');
      expect(moodEntry.note, 'Test note');
      expect(moodEntry.timestamp, DateTime.parse('2024-01-15T10:30:00.000Z'));
    });

    test('should convert MoodEntry to JSON', () {
      // Arrange
      final timestamp = DateTime.parse('2024-01-15T10:30:00.000Z');
      final moodEntry = MoodEntry(
        id: 'test-id',
        mood: 'Happy',
        emoji: '😊',
        note: 'Test note',
        timestamp: timestamp,
      );

      // Act
      final json = moodEntry.toJson();

      // Assert
      expect(json['id'], 'test-id');
      expect(json['mood'], 'Happy');
      expect(json['emoji'], '😊');
      expect(json['note'], 'Test note');
      expect(json['timestamp'], '2024-01-15T10:30:00.000Z');
    });

    test('should handle empty note', () {
      // Arrange
      final json = {
        'id': 'test-id',
        'mood': 'Happy',
        'emoji': '😊',
        'note': '',
        'timestamp': '2024-01-15T10:30:00.000Z',
      };

      // Act
      final moodEntry = MoodEntry.fromJson(json);

      // Assert
      expect(moodEntry.note, '');
    });
  });
}