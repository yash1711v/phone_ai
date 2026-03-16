// Firebase options for PROD flavor (OM-101 project).
// Copy api_key from downloaded google-services.json (Android) and GoogleService-Info.plist (iOS).
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptionsProd {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptionsProd have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptionsProd are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC551GZW7RRee4yaJZuTcR81p4nQky8R-I',
    appId: '1:744913677085:android:cfd61ef73bb31355314ff4',
    messagingSenderId: '744913677085',
    projectId: 'om-101',
    storageBucket: 'om-101.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD10jaI7dLYwmkEPHKUk011omu_LlSk-Ys',
    appId: '1:744913677085:ios:6bf158d8cb87a846314ff4',
    messagingSenderId: '744913677085',
    projectId: 'om-101',
    storageBucket: 'om-101.firebasestorage.app',
    iosClientId: '744913677085-20ehabn7gk5vt680trn9ie1cbueb29lu.apps.googleusercontent.com',
    iosBundleId: 'com.bfc.openmic',
  );
}
