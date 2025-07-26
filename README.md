# Mood Tracker: Production-Ready Mental Health App

**Mood Tracker** is a production-grade, cross-platform Flutter application designed for secure mood tracking and mental health awareness. Built with enterprise-level security, comprehensive testing, and privacy-first architecture.

[![Build Status](https://github.com/yourusername/mood-tracker/workflows/CI%2FCD%20Pipeline/badge.svg)](https://github.com/yourusername/mood-tracker/actions)
[![Coverage](https://img.shields.io/badge/coverage-80%25+-green.svg)](https://github.com/yourusername/mood-tracker)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🌟 Key Features

### Core Functionality
- **Secure Mood Tracking**: Record daily moods with emojis, ratings, and encrypted notes
- **Advanced Analytics**: Beautiful charts and trend analysis with historical insights
- **Calendar Integration**: Browse mood history with intuitive calendar interface
- **Smart Notifications**: Customizable daily reminders with timezone support
- **Offline Support**: Full functionality without internet connection
- **Data Export**: Encrypted backup and CSV export for analysis

### 🔒 Production-Grade Security
- **AES-256 Encryption**: Military-grade encryption for all mood data
- **Local-Only Storage**: No cloud storage, complete privacy
- **Data Integrity**: Hash verification and corruption detection
- **Zero Data Collection**: We don't collect or access your personal data
- **GDPR/CCPA Compliant**: Full privacy compliance for global users

### 🚀 Enterprise Features
- **Comprehensive Testing**: 80%+ test coverage with unit, widget, and integration tests
- **Performance Monitoring**: Real-time performance tracking and optimization
- **Crash Reporting**: Anonymous crash analytics via Firebase Crashlytics
- **CI/CD Pipeline**: Automated testing, building, and deployment
- **Database Migration**: Seamless SQLite migration with data integrity verification
- **Error Recovery**: Robust error handling with automatic retry mechanisms

## 📱 App Architecture

### MVVM with Clean Architecture
The app follows **Model-View-ViewModel (MVVM)** pattern with clean architecture principles:

- **Models** (`lib/models/`): Data classes with JSON serialization
- **ViewModels** (`lib/viewmodels/`): Business logic extending BaseViewModel
- **Views** (`lib/screens/`, `lib/widgets/`): UI components consuming ViewModels
- **Services** (`lib/services/`): Core functionality (storage, security, analytics)

### Key Architectural Decisions
- **Provider Pattern**: State management with dependency injection
- **SQLite Database**: Encrypted local storage with migration support
- **Service Layer**: Separation of concerns with dedicated services
- **Error Boundaries**: Centralized error handling with BaseViewModel
- **Performance First**: Optimized widgets and monitoring throughout

## 🏗️ Technical Stack

### Core Technologies
- **Flutter 3.19+**: Cross-platform mobile framework
- **Dart 3.0+**: Programming language
- **SQLite**: Local database with encryption
- **Provider**: State management
- **Firebase**: Crashlytics for anonymous error reporting

### Security & Encryption
- **AES-256**: Symmetric encryption for mood data
- **SHA-256**: Data integrity verification
- **Secure Key Generation**: Random key generation with proper storage

### Testing & Quality
- **Unit Tests**: Models, services, and ViewModels testing
- **Widget Tests**: UI component testing with accessibility
- **Integration Tests**: End-to-end user flow testing
- **Mockito**: Service mocking for isolated testing
- **Coverage**: 80%+ code coverage requirement

### Performance & Monitoring
- **Performance Service**: Real-time operation tracking
- **Memory Monitoring**: Leak detection and usage tracking
- **Database Optimization**: Query performance and indexing
- **Widget Profiling**: Build time monitoring and optimization

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.19.0 or higher
- **Dart SDK**: 3.0.0 or higher  
- **Android Studio**: For Android development and emulators
- **Xcode**: For iOS development (macOS only)
- **Firebase Project**: For crash reporting (optional)

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/mood-tracker.git
   cd mood-tracker
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate code (for mocks and build_runner):**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **Setup Firebase (optional):**
   ```bash
   # Copy example Firebase config files
   cp android/app/google-services.json.example android/app/google-services.json
   cp ios/Runner/GoogleService-Info.plist.example ios/Runner/GoogleService-Info.plist
   ```

### Running the App

**Development:**
```bash
flutter run                    # Run on available device/emulator
flutter run -d android         # Run on Android device/emulator
flutter run -d ios             # Run on iOS device/emulator (macOS only)
flutter run -d chrome          # Run on web browser
```

**Production Build:**
```bash
flutter build apk              # Build Android APK
flutter build appbundle        # Build Android App Bundle (preferred)
flutter build ios              # Build iOS app (macOS only)
flutter build web              # Build web app
```

### Development Commands

**Code Quality:**
```bash
flutter analyze                # Static analysis and linting
flutter test                   # Run unit tests
flutter test --coverage        # Run tests with coverage report
flutter test integration_test/ # Run integration tests
flutter doctor                 # Check Flutter installation
```

**Performance:**
```bash
flutter run --profile          # Run in profile mode for performance testing
flutter build apk --analyze-size # Analyze app size
```

## 📁 Project Structure

```text
mood-tracker/
├── lib/
│   ├── main.dart                 # App entry point with service initialization
│   ├── constants/                # Static data and configuration
│   │   └── mood_data.dart        # Mood definitions and constants
│   ├── models/                   # Data models with JSON serialization
│   │   └── mood_entry.dart       # Core mood entry model
│   ├── screens/                  # UI pages and navigation
│   │   ├── analytics_page.dart   # Analytics and charts screen
│   │   ├── calendar_page.dart    # Calendar view for mood history
│   │   ├── login_page.dart       # Authentication screen
│   │   ├── main_navigation_page.dart # Bottom navigation
│   │   ├── mood_home_page.dart   # Main mood tracking screen
│   │   └── settings_page.dart    # App settings and preferences
│   ├── services/                 # Core business services
│   │   ├── analytics_service.dart       # Mood analytics and calculations
│   │   ├── connectivity_service.dart    # Network connectivity monitoring
│   │   ├── crash_reporting_service.dart # Anonymous crash reporting
│   │   ├── database_service.dart        # SQLite database operations
│   │   ├── encryption_service.dart      # AES-256 encryption
│   │   ├── export_service.dart          # Data export functionality
│   │   ├── migration_service.dart       # Database migration management
│   │   ├── mood_database_storage.dart   # Database-backed storage
│   │   ├── mood_storage.dart            # Legacy SharedPrefs storage
│   │   ├── notification_service.dart    # Daily mood reminders
│   │   ├── performance_service.dart     # Performance monitoring
│   │   └── theme_service.dart           # Theme management
│   ├── utils/                    # Helper utilities and extensions
│   │   ├── animations.dart       # Custom animations
│   │   ├── date_utils.dart       # Date formatting helpers
│   │   └── performance_utils.dart # Performance optimization utilities
│   ├── viewmodels/               # MVVM business logic layer
│   │   ├── analytics_view_model.dart    # Analytics screen logic
│   │   ├── base_view_model.dart         # Base class with error handling
│   │   ├── calendar_view_model.dart     # Calendar screen logic
│   │   ├── mood_view_model.dart         # Mood tracking logic
│   │   ├── navigation_view_model.dart   # Navigation state management
│   │   └── view_models.dart             # ViewModel exports
│   └── widgets/                  # Reusable UI components
│       ├── add_mood_dialog.dart         # Mood entry dialog
│       ├── empty_state_widget.dart      # Empty state displays
│       ├── mood_card.dart               # Individual mood display
│       └── optimized_mood_card.dart     # Performance-optimized version
├── test/                         # Unit and widget tests
│   ├── models/                   # Model tests
│   ├── services/                 # Service tests
│   ├── viewmodels/               # ViewModel tests
│   └── widgets/                  # Widget tests
├── integration_test/             # End-to-end integration tests
├── .github/                      # GitHub Actions CI/CD
│   ├── workflows/
│   │   ├── ci-cd.yml            # Main CI/CD pipeline
│   │   ├── pr-checks.yml        # Pull request validation
│   │   └── release.yml          # Release automation
│   └── ISSUE_TEMPLATE/          # Bug reports and feature requests
├── app_store_metadata/          # App store listing materials
│   ├── app_description.md       # App store descriptions
│   ├── google_play_metadata.md  # Google Play specific metadata
│   ├── privacy_policy.md        # Privacy policy document
│   ├── release_checklist.md     # Pre-release validation
│   └── screenshot_requirements.md # Asset specifications
├── android/                     # Android-specific configuration
├── ios/                        # iOS-specific configuration
├── CLAUDE.md                   # Development guidance for AI assistants
└── README.md                   # This file
```

## 🧪 Testing Strategy

### Test Coverage Requirements
- **Minimum Coverage**: 80% overall
- **Unit Tests**: All models, services, and ViewModels
- **Widget Tests**: All custom widgets and screens
- **Integration Tests**: Critical user flows

### Running Tests
```bash
# Run all tests with coverage
flutter test --coverage

# Run specific test suites
flutter test test/models/
flutter test test/services/
flutter test test/viewmodels/
flutter test test/widgets/

# Run integration tests
flutter test integration_test/

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 🔒 Security & Privacy

### Data Protection
- **Local-Only Storage**: All data remains on user's device
- **AES-256 Encryption**: Military-grade encryption for mood entries
- **Zero Data Collection**: No personal information collected or transmitted
- **Data Integrity**: Hash verification prevents data tampering
- **Secure Backup**: Encrypted export/import functionality

### Privacy Compliance
- **GDPR Compliant**: Full user control over personal data
- **CCPA Compliant**: No sale or sharing of personal information
- **COPPA Safe**: No data collection from users of any age
- **Transparent**: Open-source code for full transparency

## 🚀 Deployment & CI/CD

### Automated Pipeline
- **GitHub Actions**: Automated testing, building, and deployment
- **Quality Gates**: 80% test coverage requirement
- **Security Scanning**: Dependency audits and secret detection
- **Multi-Platform**: Android APK/AAB and iOS builds
- **Performance Testing**: App size limits and optimization checks

### Release Process
1. **Automated Testing**: All tests must pass
2. **Security Audit**: Dependency and code scanning
3. **Performance Validation**: Size and speed requirements
4. **Manual QA**: Device testing and user flow validation
5. **App Store Submission**: Automated release to stores

## 🤝 Contributing

We welcome contributions! Please see our contribution guidelines:

### Getting Started
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes with tests
4. Ensure all tests pass (`flutter test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Code Standards
- Follow Flutter/Dart style guidelines
- Maintain 80%+ test coverage
- Add documentation for new features
- Use conventional commit messages
- Ensure CI pipeline passes

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for crash reporting infrastructure
- Open source community for inspiration and support

---

**Built with ❤️ for mental health awareness and privacy**
