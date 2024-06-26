// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCNrnbyqZzkfDabMLlfUJuDt-eHGq8jsx8',
    appId: '1:900851158271:web:f664ebefeeb635362a50ca',
    messagingSenderId: '900851158271',
    projectId: 'acapella-app-final',
    authDomain: 'acapella-app-final.firebaseapp.com',
    storageBucket: 'acapella-app-final.appspot.com',
    measurementId: 'G-KK3R495GKB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB6PabUTLMkc7zXjSJopcrU4x8YQry-gSs',
    appId: '1:900851158271:android:315fe2a9670481e72a50ca',
    messagingSenderId: '900851158271',
    projectId: 'acapella-app-final',
    storageBucket: 'acapella-app-final.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAIVaJA1yR6yFEUZe3owOu1xebKurSOnps',
    appId: '1:900851158271:ios:fa77385f5fe21ae52a50ca',
    messagingSenderId: '900851158271',
    projectId: 'acapella-app-final',
    storageBucket: 'acapella-app-final.appspot.com',
    iosBundleId: 'com.example.acapellaApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAIVaJA1yR6yFEUZe3owOu1xebKurSOnps',
    appId: '1:900851158271:ios:fa77385f5fe21ae52a50ca',
    messagingSenderId: '900851158271',
    projectId: 'acapella-app-final',
    storageBucket: 'acapella-app-final.appspot.com',
    iosBundleId: 'com.example.acapellaApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCNrnbyqZzkfDabMLlfUJuDt-eHGq8jsx8',
    appId: '1:900851158271:web:86162c643daf044f2a50ca',
    messagingSenderId: '900851158271',
    projectId: 'acapella-app-final',
    authDomain: 'acapella-app-final.firebaseapp.com',
    storageBucket: 'acapella-app-final.appspot.com',
    measurementId: 'G-B7MB1JLTED',
  );

}