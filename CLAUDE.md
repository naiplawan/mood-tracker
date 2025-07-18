# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

**Install dependencies:**
```bash
flutter pub get
```

**Run the app:**
```bash
flutter run                    # Run on available device/emulator
flutter run -d android         # Run on Android device/emulator
flutter run -d ios             # Run on iOS device/emulator
flutter run -d chrome          # Run on web browser
```

**Code quality:**
```bash
flutter analyze                # Static analysis and linting
flutter test                   # Run unit tests
```

**Build:**
```bash
flutter build apk              # Build Android APK
flutter build ios              # Build iOS app
flutter build web              # Build web app
```

## Architecture Overview

This Flutter app follows **MVVM (Model-View-ViewModel)** architecture with Provider for state management:

### Core Architecture Patterns

- **Models** (`lib/models/`): Data classes like `MoodEntry` with JSON serialization
- **ViewModels** (`lib/viewmodels/`): Business logic and state management extending `BaseViewModel`
- **Views** (`lib/screens/`, `lib/widgets/`): UI components that consume ViewModels via Provider
- **Services** (`lib/services/`): Data persistence, notifications, themes, analytics, and export functionality

### Key Components

**BaseViewModel** (`lib/viewmodels/base_view_model.dart`):
- Abstract base class for all ViewModels
- Provides common loading states, error handling, and async operation management
- All ViewModels extend this for consistent state management patterns

**Provider Setup** (`lib/main.dart`):
- MultiProvider configuration with all ViewModels
- ChangeNotifierProxyProvider for ViewModels with dependencies (e.g., NavigationViewModel depends on MoodViewModel)
- Services initialized before app startup (ThemeService, NotificationService)

**Data Storage** (`lib/services/mood_storage.dart`):
- Uses SharedPreferences for local persistence
- JSON serialization/deserialization of mood entries
- Automatic sorting by timestamp (newest first)

### State Management Flow

1. UI triggers actions on ViewModels
2. ViewModels use `handleAsync()` from BaseViewModel for loading/error states
3. ViewModels call Services for data operations
4. UI rebuilds automatically via Provider/ChangeNotifier pattern

### Dependencies

Key packages:
- `provider`: State management
- `shared_preferences`: Local data storage
- `fl_chart`: Analytics charts
- `table_calendar`: Calendar widget
- `flutter_local_notifications`: Daily mood reminders
- `csv`: Data export functionality

## File Organization

- `lib/constants/`: Static data (mood definitions, colors)
- `lib/models/`: Data models with JSON serialization
- `lib/screens/`: Main UI pages (home, calendar, analytics, settings)
- `lib/services/`: Business services (storage, notifications, themes, export)
- `lib/utils/`: Helper functions and animations
- `lib/viewmodels/`: MVVM ViewModels extending BaseViewModel
- `lib/widgets/`: Reusable UI components

## Key Implementation Notes

- All ViewModels must extend `BaseViewModel` for consistent error/loading handling
- Use `handleAsync()` wrapper for all async operations in ViewModels
- MoodEntry data is stored locally via SharedPreferences as JSON
- The app uses a dark theme by default with Web3-style theming
- Navigation is handled via NavigationViewModel with bottom navigation
- Notifications require proper timezone setup and permissions