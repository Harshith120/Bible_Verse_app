# Daily Bible Verse App

A modern, cross-platform **Flutter & Dart** application delivering daily Bible verses with REST API integration, offline SQLite local caching, Firebase Authentication, Unit & Widget testing, and an automated GitHub Actions CI workflow.

---

## 🌟 Key Features

1. **REST API Integration with Error & Loading States**:
   - Fetches verse of the day from `https://bible-api.com`.
   - Handles network timeouts, HTTP errors (404/500), and invalid JSON format.
   - Smooth `LoadingIndicator` and `ErrorView` with retry action.
   - Ability to fetch random verses on demand.

2. **Offline Local Storage with SQLite**:
   - Uses `sqflite` for caching daily verses locally.
   - Provides offline fallback: if network request fails, loads cached verses seamlessly.
   - Manages user bookmarks with CRUD operations stored in SQLite database.

3. **Firebase Authentication**:
   - Email and Password Authentication (Sign In & Sign Up).
   - Form validation, error message mapping (e.g., `user-not-found`, `wrong-password`).
   - Clean user session state persistence across app lifecycle.

4. **Clean Architecture & State Management**:
   - Utilizes `Provider` for reactive state management.
   - Separation of concerns: Data Models, Services, Repositories, Providers, and UI Views.

5. **Unit & Widget Testing**:
   - Comprehensive test suite in `test/unit` and `test/widget`.
   - Mocking API client, SQLite database, and Auth service using `mockito`.

6. **Automated GitHub Actions CI**:
   - Continuous Integration workflow (`.github/workflows/flutter_ci.yml`).
   - Automated formatting check, static code analysis (`flutter analyze`), and unit & widget test execution (`flutter test`).

---

## 📁 Project Structure

```
Bible_Verse_app/
├── .github/
│   └── workflows/
│       └── flutter_ci.yml
├── lib/
│   ├── main.dart                  # Application entry point & MultiProvider setup
│   ├── firebase_options.dart      # Firebase options setup
│   ├── models/
│   │   ├── verse.dart             # Verse model with JSON & SQLite mappers
│   │   └── user_model.dart        # User profile model
│   ├── services/
│   │   ├── api_service.dart       # REST API HTTP client
│   │   ├── database_helper.dart   # SQLite database & DAO
│   │   └── auth_service.dart      # Firebase Authentication service
│   ├── repositories/
│   │   ├── verse_repository.dart  # Data repository orchestrating API + SQLite
│   │   └── auth_repository.dart   # Authentication repository
│   ├── providers/
│   │   ├── verse_provider.dart    # Daily verse state management
│   │   ├── bookmarks_provider.dart# Bookmarked verses state management
│   │   └── auth_provider.dart     # Authentication state management
│   ├── screens/
│   │   ├── home_screen.dart       # Main daily verse display
│   │   ├── bookmarks_screen.dart  # SQLite bookmarked verses list
│   │   ├── login_screen.dart      # Sign In screen
│   │   └── register_screen.dart   # Sign Up screen
│   └── widgets/
│       ├── verse_card.dart        # Styled verse card with copy & bookmark action
│       ├── error_view.dart        # Friendly error view with retry button
│       └── loading_indicator.dart # Loading state view
└── test/
    ├── unit/
    │   ├── api_service_test.dart
    │   ├── verse_repository_test.dart
    │   └── auth_service_test.dart
    └── widget/
        ├── verse_card_test.dart
        ├── error_view_test.dart
        ├── home_screen_test.dart
        └── login_screen_test.dart
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>=3.0.0`)
- [Dart SDK](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) or VS Code

### Installation & Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/bible_verse_app.git
   cd bible_verse_app
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run tests**:
   ```bash
   flutter test
   ```

4. **Run the application**:
   ```bash
   flutter run
   ```

---

## 🧪 Testing

Run all unit and widget tests:
```bash
flutter test
```

Generate coverage report:
```bash
flutter test --coverage
```

---

## 🔄 GitHub Actions CI Workflow

The workflow at `.github/workflows/flutter_ci.yml` runs on every `push` and `pull_request` to `main`:
1. **Set up Flutter SDK and Java 17**
2. **`flutter pub get`**
3. **`dart format --set-exit-if-changed .`**
4. **`flutter analyze`**
5. **`flutter test --coverage`**

---

## 📄 License
This project is open-source and licensed under the MIT License.
