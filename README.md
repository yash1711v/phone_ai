# Phone AI - Openmic Flutter App

A Flutter application built with Clean Architecture, featuring Firebase authentication, LiveKit integration, and comprehensive analytics.

## Architecture

This project follows Clean Architecture principles with the following structure:

```
lib/
├── core/              # Core utilities, constants, network, theme
├── features/          # Feature modules (auth, home, profile)
│   └── auth/         # Authentication feature
│       ├── data/     # Data layer (models, datasources, repositories)
│       ├── domain/   # Domain layer (entities, repositories, usecases)
│       └── presentation/ # Presentation layer (BLoC, pages, widgets)
├── shared/           # Shared widgets and services
└── di/               # Dependency injection
```

## Features

- ✅ Firebase Authentication (Email, Google, Apple)
- ✅ Phone OTP verification for unregistered emails
- ✅ Theme management with BLoC/Cubit
- ✅ API integration with Dio
- ✅ LiveKit integration for voice calls
- ✅ Firebase Analytics & Crashlytics
- ✅ Clean Architecture
- ✅ Routing with animations
- ✅ Permission handling

## Setup Instructions

### 1. Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android and iOS apps to your Firebase project
3. Download configuration files:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`

### 2. Google Sign-In Setup

#### Android
- Add SHA-1 fingerprint to Firebase Console
- Get SHA-1: `cd android && ./gradlew signingReport`

#### iOS
- Configure OAuth client in Firebase Console
- Add URL scheme in `ios/Runner/Info.plist`

### 3. Apple Sign-In Setup

- Enable Sign in with Apple capability in Xcode
- Configure in Apple Developer Portal

### 4. API Configuration

Update `lib/core/constants/api_constants.dart` with your API base URL:

```dart
static const String baseUrl = 'https://your-api-url.com/v1';
```

### 5. LiveKit Configuration

1. Set up LiveKit server
2. Update LiveKit URL and token generation endpoint in your API

### 6. Install Dependencies

```bash
flutter pub get
```

### 7. Generate Code (for dependency injection)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Running the App

```bash
flutter run
```

## Project Structure

### Core
- **constants/**: API endpoints, app strings, colors
- **error/**: Exception and failure classes
- **network/**: API client, interceptors, network info
- **theme/**: Theme cubit and theme data
- **routes/**: App routing configuration
- **utils/**: Logger, debounce, permission handler

### Features
Each feature follows Clean Architecture:
- **data/**: Models, remote/local datasources, repository implementations
- **domain/**: Entities, repository interfaces, use cases
- **presentation/**: BLoC, pages, widgets

### Shared
- **services/**: Analytics, notifications, LiveKit
- **widgets/**: Reusable UI components

## Authentication Flow

1. **Email Login**: User enters email/password
2. **Email Check**: If email not registered, prompt for phone number
3. **OTP Flow**: Send OTP to phone, verify OTP
4. **Social Login**: Google/Apple sign-in options

## LiveKit Integration

Example usage:

```dart
final liveKitService = getIt<LiveKitService>();

// Connect to room
await liveKitService.connect(
  token: 'your-livekit-token',
  url: 'wss://your-livekit-server.com',
);

// Enable microphone
await liveKitService.enableMicrophone();

// Disconnect
await liveKitService.disconnect();
```

## Testing

Run tests:

```bash
flutter test
```

## Building

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Environment Variables

Create a `.env` file (not committed) for sensitive data:
- API keys
- LiveKit URLs
- Firebase config (if using environment-specific configs)

## License

[Your License Here]
# phone_ai
