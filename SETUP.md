# Setup Guide

## Prerequisites

- Flutter SDK (3.9.2 or higher)
- Android Studio / Xcode
- Firebase account
- LiveKit server (optional for now)

## Step-by-Step Setup

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Firebase Setup

#### Android
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create/Select project
3. Add Android app
4. Download `google-services.json`
5. Place it in `android/app/`
6. Add to `android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```
7. Add to `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

#### iOS
1. Add iOS app in Firebase Console
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/`
4. Open `ios/Runner.xcworkspace` in Xcode
5. Drag `GoogleService-Info.plist` into Xcode project

### 3. Google Sign-In Setup

#### Android
1. Get SHA-1 fingerprint:
   ```bash
   cd android
   ./gradlew signingReport
   ```
2. Copy SHA-1 from output
3. Add to Firebase Console → Project Settings → Your Android App

#### iOS
1. In Firebase Console → Authentication → Sign-in method
2. Enable Google Sign-In
3. Add iOS bundle ID

### 4. Apple Sign-In Setup

#### iOS
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to Signing & Capabilities
4. Click "+ Capability"
5. Add "Sign in with Apple"

### 5. Update API Constants

Edit `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'https://your-actual-api-url.com/v1';
```

### 6. Generate Code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 7. Run the App

```bash
flutter run
```

## Testing Authentication

1. **Email/Password**: Use Firebase Console to create test users
2. **Google Sign-In**: Test with your Google account
3. **Apple Sign-In**: Test on iOS device/simulator
4. **Phone OTP**: Configure Firebase Phone Auth in Console

## Common Issues

### Build Errors
- Run `flutter clean` then `flutter pub get`
- Delete `build/` folder if issues persist

### Firebase Errors
- Ensure `google-services.json` / `GoogleService-Info.plist` are in correct locations
- Check package name matches Firebase project

### Permission Errors
- Check AndroidManifest.xml and Info.plist have required permissions
- Request permissions at runtime before using features

## Next Steps

1. Implement home feature
2. Implement profile feature
3. Add more LiveKit features
4. Add unit tests
5. Add integration tests
