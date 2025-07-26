import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_notes_app/widgets/mood_card.dart';
import 'package:mood_notes_app/models/mood_entry.dart';

void main() {
  group('MoodCard Widget', () {
    late MoodEntry testEntry;

    setUp(() {
      testEntry = MoodEntry(
        id: 'test-id',
        mood: 'Happy',
        emoji: '😊',
        note: 'This is a test note',
        timestamp: DateTime(2024, 1, 15, 14, 30),
      );
    });

    testWidgets('should display mood information correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoodCard(
              entry: testEntry,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('😊'), findsOneWidget);
      expect(find.text('Happy'), findsOneWidget);
      expect(find.text('This is a test note'), findsOneWidget);
    });

    testWidgets('should handle tap events', (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoodCard(
              entry: testEntry,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(MoodCard));
      await tester.pumpAndSettle();

      // Assert
      expect(wasTapped, true);
    });

    testWidgets('should display empty note gracefully', (WidgetTester tester) async {
      // Arrange
      final entryWithEmptyNote = MoodEntry(
        id: 'test-id',
        mood: 'Happy',
        emoji: '😊',
        note: '',
        timestamp: DateTime(2024, 1, 15, 14, 30),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoodCard(
              entry: entryWithEmptyNote,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('😊'), findsOneWidget);
      expect(find.text('Happy'), findsOneWidget);
      // Should not crash with empty note
    });

    testWidgets('should be accessible', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoodCard(
              entry: testEntry,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert - Check for semantic labels
      final semantics = tester.getSemantics(find.byType(MoodCard));
      expect(semantics.label, isNotEmpty);
    });
  });
}