// Firebase configuration for Villages Connect
// This file contains Firebase project configuration
// In a real app, these values would come from your Firebase console

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Web configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'demo_api_key_web',
    appId: '1:123456789:web:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'villages-connect-demo',
    authDomain: 'villages-connect-demo.firebaseapp.com',
    storageBucket: 'villages-connect-demo.appspot.com',
    measurementId: 'G-ABCDEFGHIJ',
  );

  // Android configuration
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'demo_api_key_android',
    appId: '1:123456789:android:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'villages-connect-demo',
    storageBucket: 'villages-connect-demo.appspot.com',
  );

  // iOS configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'demo_api_key_ios',
    appId: '1:123456789:ios:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'villages-connect-demo',
    storageBucket: 'villages-connect-demo.appspot.com',
    iosBundleId: 'com.villages.connect',
  );

  // macOS configuration
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'demo_api_key_macos',
    appId: '1:123456789:macos:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'villages-connect-demo',
    storageBucket: 'villages-connect-demo.appspot.com',
    iosBundleId: 'com.villages.connect',
  );

  // Windows configuration
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'demo_api_key_windows',
    appId: '1:123456789:windows:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'villages-connect-demo',
    storageBucket: 'villages-connect-demo.appspot.com',
  );

  // Linux configuration
  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'demo_api_key_linux',
    appId: '1:123456789:linux:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'villages-connect-demo',
    storageBucket: 'villages-connect-demo.appspot.com',
  );
}