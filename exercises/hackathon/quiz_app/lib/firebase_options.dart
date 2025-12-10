// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart' show TargetPlatform;

class DefaultFirebaseOptions {
  /// 依照目前平台，回傳對應的 FirebaseOptions
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      // 之後如果要支援 Android，可以在這裡再加 case
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions 不支援目前這個平台：$defaultTargetPlatform',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAk39ujUf44xEsy1sPYT_TYSKmJiCufnog',
    appId: '1:416525599926:web:f9b6b81095b1a825995217',
    messagingSenderId: '416525599926',
    projectId: 'quizzes-cfe9f',
    authDomain: 'quizzes-cfe9f.firebaseapp.com',
    storageBucket: 'quizzes-cfe9f.firebasestorage.app',
  );

  // ---------- Web 設定 ----------

  // ---------- iOS 設定 ----------
  static const FirebaseOptions ios = FirebaseOptions(
    // 從 ios/Runner/GoogleService-Info.plist 抄的
    apiKey: 'AIzaSyCfONRl1lfJmogsU4Xgi820AQ6tL0_ySI8',
    appId: '1:416525599926:ios:df05c79457981b01995217',
    messagingSenderId: '416525599926',
    projectId: 'quizzes-cfe9f',
    storageBucket: 'quizzes-cfe9f.appspot.com',
    iosBundleId: 'com.example.quizApp',
    iosClientId: '416525599926-sqtp8tmk2lmij12k24dqu15ig4829vak.apps.googleusercontent.com',
  );
}