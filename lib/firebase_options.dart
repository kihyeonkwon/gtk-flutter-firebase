// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDi2CWBtnL5SPXMEUTThSocil8LhYA-17w',
    appId: '1:802183251586:web:eb66d9220e75e110fdd69b',
    messagingSenderId: '802183251586',
    projectId: 'gtk-flutter-firebase-35d77',
    authDomain: 'gtk-flutter-firebase-35d77.firebaseapp.com',
    storageBucket: 'gtk-flutter-firebase-35d77.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyChsLIc8ALjZvRfDYosfvAqpG_KIycBK1g',
    appId: '1:802183251586:android:8066a0a2e61d28cafdd69b',
    messagingSenderId: '802183251586',
    projectId: 'gtk-flutter-firebase-35d77',
    storageBucket: 'gtk-flutter-firebase-35d77.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDveSxLXgrf3-d8_ZHtHggK_B4F3BidQog',
    appId: '1:802183251586:ios:e2364c9072d8b137fdd69b',
    messagingSenderId: '802183251586',
    projectId: 'gtk-flutter-firebase-35d77',
    storageBucket: 'gtk-flutter-firebase-35d77.appspot.com',
    iosClientId: '802183251586-j1undubhq68b7a8itl8g28co39c517qa.apps.googleusercontent.com',
    iosBundleId: 'com.example.gtkFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDveSxLXgrf3-d8_ZHtHggK_B4F3BidQog',
    appId: '1:802183251586:ios:e2364c9072d8b137fdd69b',
    messagingSenderId: '802183251586',
    projectId: 'gtk-flutter-firebase-35d77',
    storageBucket: 'gtk-flutter-firebase-35d77.appspot.com',
    iosClientId: '802183251586-j1undubhq68b7a8itl8g28co39c517qa.apps.googleusercontent.com',
    iosBundleId: 'com.example.gtkFlutter',
  );
}
