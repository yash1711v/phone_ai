// Firebase options for DEV flavor (openmic-staging project).
// Copy api_key from downloaded google-services.json (Android) and GoogleService-Info.plist (iOS).
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptionsDev {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptionsDev have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptionsDev are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDiehwplXUFiY738Kik7tcz7daeKF2Xa7Q',
    appId: '1:540801659623:android:de51f3a3ee8b0529762842',
    messagingSenderId: '540801659623',
    projectId: 'openmic-staging-6f504',
    storageBucket: 'openmic-staging-6f504.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD4RyIXrYmej5zFmJa200Vf1FojYHjWWz8',
    appId: '1:540801659623:ios:7dbb3284dd829678762842',
    messagingSenderId: '540801659623',
    projectId: 'openmic-staging-6f504',
    storageBucket: 'openmic-staging-6f504.firebasestorage.app',
    iosClientId: '540801659623-nuome5rbr5550lb9ebegescrnjfq5tne.apps.googleusercontent.com',
    iosBundleId: 'com.bfc.openmic',
  );
}
