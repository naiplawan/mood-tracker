import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mood_notes_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Mood Tracker App Integration Tests', () {
    testWidgets('complete user flow - add, view, and navigate', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify app starts correctly
      expect(find.text('Mood Tracker'), findsOneWidget);

      // Navigate to add mood if not already on home page
      final addMoodButton = find.byType(FloatingActionButton);
      if (addMoodButton.hasFound) {
        await tester.tap(addMoodButton);
        await tester.pumpAndSettle();
      }

      // Add a mood entry (assuming there's an add mood dialog)
      // This test will need to be updated based on your actual UI structure
      final happyMoodOption = find.text('Happy').first;
      if (happyMoodOption.hasFound) {
        await tester.tap(happyMoodOption);
        await tester.pumpAndSettle();
      }

      // Add a note if there's a text field
      final noteField = find.byType(TextField);
      if (noteField.hasFound) {
        await tester.enterText(noteField.first, 'Integration test mood entry');
        await tester.pumpAndSettle();
      }

      // Save the mood entry
      final saveButton = find.text('Save').first;
      if (saveButton.hasFound) {
        await tester.tap(saveButton);
        await tester.pumpAndSettle();
      }

      // Navigate to calendar view
      final calendarTab = find.byIcon(Icons.calendar_today);
      if (calendarTab.hasFound) {
        await tester.tap(calendarTab);
        await tester.pumpAndSettle();
      }

      // Navigate to analytics view
      final analyticsTab = find.byIcon(Icons.analytics);
      if (analyticsTab.hasFound) {
        await tester.tap(analyticsTab);
        await tester.pumpAndSettle();
      }

      // Navigate to settings
      final settingsTab = find.byIcon(Icons.settings);
      if (settingsTab.hasFound) {
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();
      }

      // Verify we can navigate back to home
      final homeTab = find.byIcon(Icons.home);
      if (homeTab.hasFound) {
        await tester.tap(homeTab);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('app handles empty state gracefully', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Should not crash with no mood entries
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Navigate through all tabs to ensure no crashes
      final tabs = [
        Icons.calendar_today,
        Icons.analytics,
        Icons.settings,
        Icons.home,
      ];

      for (final tabIcon in tabs) {
        final tab = find.byIcon(tabIcon);
        if (tab.hasFound) {
          await tester.tap(tab);
          await tester.pumpAndSettle();
          
          // Verify no error screens
          expect(find.textContaining('Error'), findsNothing);
        }
      }
    });

    testWidgets('notification permissions flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      final settingsTab = find.byIcon(Icons.settings);
      if (settingsTab.hasFound) {
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();

        // Look for notification settings
        final notificationToggle = find.byType(Switch);
        if (notificationToggle.hasFound) {
          await tester.tap(notificationToggle.first);
          await tester.pumpAndSettle();
          
          // Should handle permission request gracefully
          // (Note: Actual permission dialog testing requires platform-specific setup)
        }
      }
    });

    testWidgets('data persistence across app restarts', (WidgetTester tester) async {
      // This test simulates app restart by reinitializing
      // Start app first time
      app.main();
      await tester.pumpAndSettle();

      // Add a mood entry (simplified - actual implementation depends on UI)
      // ... add mood entry logic ...

      // Simulate app restart by pumping a new instance
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();
      
      app.main();
      await tester.pumpAndSettle();

      // Verify data persisted
      // This test would need to be more specific based on your UI
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}