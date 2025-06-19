# Mood Notes App

A beautiful Flutter application for tracking your daily moods with notes and timestamps.

## Features

- 📱 Beautiful and intuitive UI
- 😊 5 different mood categories with emojis
- 📝 Optional notes for each mood entry
- 📅 Timestamp tracking with smart date formatting
- 💾 Local storage using SharedPreferences
- 🗑️ Delete mood entries with confirmation
- ✨ Smooth animations and transitions
- 📱 Responsive design

## Project Structure

```text
lib/
├── main.dart                    # App entry point and theme configuration
├── constants/
│   └── mood_data.dart          # Mood definitions and color mappings
├── models/
│   └── mood_entry.dart         # MoodEntry data model
├── screens/
│   └── mood_home_page.dart     # Main screen with mood list
├── services/
│   └── mood_storage.dart       # Data persistence logic
├── utils/
│   └── date_utils.dart         # Date formatting utilities
└── widgets/
    ├── add_mood_dialog.dart    # Dialog for adding new moods
    ├── empty_state_widget.dart # Empty state display
    └── mood_card.dart          # Individual mood entry card
```

## Quick Start

1. Make sure you have Flutter installed
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Key Dependencies

- `shared_preferences: ^2.2.2` - For local data storage
- `cupertino_icons: ^1.0.2` - iOS-style icons

## Architecture

The app follows a clean architecture pattern with:

- **Models**: Data structures for mood entries
- **Services**: Business logic for data persistence
- **Widgets**: Reusable UI components
- **Screens**: Main application screens
- **Constants**: App-wide constants and configurations
- **Utils**: Helper functions and utilities

## Mood Categories

1. **Amazing** 😄 - Green
2. **Good** 😊 - Light Green  
3. **Okay** 😐 - Yellow
4. **Bad** 😞 - Orange
5. **Terrible** 😢 - Red

Each mood has its own color theme that's reflected throughout the UI.

## Mood Options

- 😄 Amazing - Green
- 😊 Good - Light Green  
- 😐 Okay - Yellow
- 😞 Bad - Orange
- 😢 Terrible - Red

The app automatically saves all your mood entries locally on your device.
