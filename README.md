# Mood Tracker

Mood Tracker is a cross-platform Flutter application that helps users log their daily moods, view historical trends, and export or analyze data over time. The app follows an MVVM architecture for maintainability and testability.

## Features

- Record mood entries with emoji, rating, and optional notes
- Calendar view to browse past mood entries
- Charts and analytics to visualize mood trends over days, weeks, and months
- Export mood data as CSV for further analysis or backup
- Local notifications to remind users to log their mood
- Light and dark theme support

## Screens

- **Login**: Secure access to your mood data
- **Home**: Quick shortcut to add today's mood entry
- **Calendar**: Browse mood history by date
- **Analytics**: View charts of mood trends
- **Settings**: Customize notifications, theme, and export options

## Architecture

The project follows the **Model-View-ViewModel (MVVM)** pattern:

- `models/` holds data classes (e.g., `MoodEntry`).
- `viewmodels/` contain business logic and state management.
- `screens/` and `widgets/` build the UI and bind to viewmodels.
- `services/` implement data storage, notifications, and export functionality.

## Getting Started

### Prerequisites

- Flutter SDK (>= 3.0)
- Dart SDK (>= 2.18)
- Android Studio or Xcode for device emulators

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/mood-tracker.git
   cd mood-tracker
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```

## Running the App

- Android:
  ```bash
  flutter run -d android
  ```

- iOS:
  ```bash
  flutter run -d ios
  ```

- Web:
  ```bash
  flutter run -d chrome
  ```

## Project Structure

```text
lib/
├── main.dart              # App entry point
├── constants/             # Static data (e.g., mood definitions)
├── models/                # Data models (e.g., MoodEntry)
├── screens/               # UI pages (e.g., mood_home_page.dart)
├── services/              # Core services (storage, notifications, export)
├── utils/                 # Helper functions and extensions
├── viewmodels/            # MVVM viewmodels
└── widgets/               # Reusable UI components
```

## Dependencies

See `pubspec.yaml` for the full list of dependencies, including packages for local storage, charts, notifications, and state management.

## Contributing

Contributions are welcome! Please open issues for bugs or feature requests, and feel free to submit pull requests.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
