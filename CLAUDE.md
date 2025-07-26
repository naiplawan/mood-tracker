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
flutter build appbundle        # Build Android App Bundle (preferred for Play Store)
flutter build ios              # Build iOS app
flutter build web              # Build web app
```

**Testing and debugging:**
```bash
flutter test                   # Run unit tests
flutter test --coverage        # Run tests with coverage report
flutter test test/specific_test.dart  # Run specific test file
flutter doctor                 # Check Flutter installation and dependencies
flutter devices                # List available devices/emulators
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
- `provider: ^6.1.2`: State management via ChangeNotifier pattern
- `shared_preferences: ^2.2.2`: Local data storage for mood entries
- `fl_chart: ^1.0.0`: Analytics charts and data visualization
- `table_calendar: ^3.0.9`: Calendar widget for mood history browsing
- `flutter_local_notifications: ^19.3.0`: Daily mood reminders with timezone support
- `csv: ^6.0.0`: Data export functionality for mood entries
- `timezone: ^0.10.1`: Timezone handling for notifications
- `permission_handler: ^12.0.0+1`: Runtime permissions for notifications
- `path_provider: ^2.1.4`: File system access for export functionality

## File Organization

- `lib/constants/`: Static data (mood definitions, colors)
- `lib/models/`: Data models with JSON serialization
- `lib/screens/`: Main UI pages (home, calendar, analytics, settings)
- `lib/services/`: Business services (storage, notifications, themes, export)
- `lib/utils/`: Helper functions and animations
- `lib/viewmodels/`: MVVM ViewModels extending BaseViewModel
- `lib/widgets/`: Reusable UI components

## Key Implementation Notes

### ViewModel Guidelines
- All ViewModels must extend `BaseViewModel` for consistent error/loading handling
- Use `handleAsync()` wrapper for all async operations in ViewModels
- ViewModels should not directly import UI components or widgets
- Follow single responsibility principle - each ViewModel handles one domain

### Data Management
- MoodEntry data is stored locally via SharedPreferences as JSON serialization
- All mood entries are automatically sorted by timestamp (newest first)
- Use `MoodStorage.loadMoodEntries()` and `MoodStorage.saveMoodEntries()` for persistence
- Data models implement `toJson()` and `fromJson()` for serialization

### UI and Theming
- The app uses a dark theme by default with Web3-style theming via `ThemeService.darkTheme`
- Navigation is handled via NavigationViewModel with bottom navigation
- UI components consume ViewModels via `Provider.of<T>()` or `Consumer<T>()` widgets

### Service Integration
- Notifications require proper timezone setup and runtime permissions
- Export functionality uses CSV format with timestamp-based filenames
- Analytics service processes mood data for trend visualization
- Theme changes persist automatically via SharedPreferences

### Development Guidelines
- Follow the MVVM pattern strictly - no business logic in UI components
- Use Provider for dependency injection and state management
- Implement proper error handling in all async operations
- Test ViewModels independently of UI components

## Common Issues & Solutions

### Build Issues
- **Gradle build failures**: Run `flutter clean && flutter pub get` to clear cache
- **iOS build issues**: Ensure Xcode is updated and run `cd ios && pod install`
- **Web build fails**: Check that web-compatible packages are used

### Development Environment
- **Hot reload not working**: Restart with `r` in terminal or `R` for hot restart
- **Device not detected**: Run `flutter doctor` and check USB debugging/developer mode
- **Package conflicts**: Delete `pubspec.lock` and run `flutter pub get`

### Runtime Issues
- **Provider errors**: Ensure ViewModels are properly registered in MultiProvider setup
  - NavigationViewModel uses ChangeNotifierProxyProvider with nullable MoodViewModel dependency
  - Always add null checks when accessing dependent ViewModels in UI components
- **Database errors**: Check SQLite initialization and migration status
- **Notification permissions**: Handle runtime permission requests for Android 13+
- **Timezone issues**: Verify timezone package initialization in main()
- **Encryption errors**: Ensure EncryptionService is initialized before data operations
- **Performance issues**: Use PerformanceService to identify bottlenecks

## Production-Grade Features

### Security & Data Protection
- **AES-256 encryption** for all mood entries with data integrity verification
- **Local-only storage** with SQLite database and automatic migration from SharedPreferences
- **No data collection** - complete user privacy with encrypted backups
- **Crash reporting** via Firebase Crashlytics (anonymous only)

### Testing Infrastructure
- **Unit tests** for models, services, and ViewModels with 80%+ coverage requirement
- **Widget tests** for UI components with accessibility testing
- **Integration tests** for complete user flows
- **Mockito** for service mocking and build_runner for code generation
- **CI/CD pipeline** with automated testing and security scans

### Performance Optimization
- **Performance monitoring** with PerformanceService tracking operation times
- **Optimized widgets** with build time profiling and caching
- **Database optimization** with proper indexing and query performance tracking
- **Memory management** with leak detection and monitoring
- **App launch tracking** and user interaction response time monitoring

### Offline Support & Error Handling
- **Robust offline mode** with pending operations queue and auto-sync
- **Comprehensive error handling** with user-friendly messages and crash reporting
- **Retry mechanisms** with exponential backoff for failed operations
- **Data integrity verification** with hash checking and corruption detection
- **Graceful degradation** when services are unavailable

### CI/CD & Deployment
- **GitHub Actions** workflows for automated testing, building, and deployment
- **Multi-platform builds** for Android (APK/AAB) and iOS with proper signing
- **Security scanning** including dependency audits and secrets detection
- **Performance testing** with app size limits and bundle analysis
- **Automated releases** to Firebase App Distribution and app stores

### App Store Readiness
- **Complete metadata** with descriptions, screenshots, and privacy policies
- **Professional assets** with proper sizing and localization support
- **Privacy compliance** with GDPR, CCPA, and COPPA adherence
- **Release checklist** with comprehensive quality assurance steps
- **Marketing materials** ready for app store optimization

## Architecture Enhancements

### Database Layer
- **SQLite with encryption** replacing SharedPreferences for better scalability
- **Migration service** for seamless data transition with integrity verification
- **Database health monitoring** with maintenance and optimization routines
- **Backup/restore** functionality with encrypted export/import

### Service Architecture  
- **Layered services** with clear separation of concerns
- **Dependency injection** via Provider with proper initialization order
- **Service health monitoring** with automatic error recovery
- **Performance tracking** across all service operations

### Error Management
- **Centralized error handling** with BaseViewModel error states
- **User-friendly error messages** with actionable guidance
- **Automatic error reporting** with context and debugging information
- **Retry mechanisms** with intelligent fallback strategies