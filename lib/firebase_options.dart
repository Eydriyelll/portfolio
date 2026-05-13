import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return web; // fallback for now
      case TargetPlatform.iOS:
        return web;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDXoqeGbNrBA3fRtCx8QV2L94j_E_VJgpU',
    authDomain: 'portfolio-b152f.firebaseapp.com',
    projectId: 'portfolio-b152f',
    storageBucket: 'portfolio-b152f.firebasestorage.app',
    messagingSenderId: '233406589023',
    appId: '1:233406589023:web:bb7efec2dd91e58084d3ea',
    measurementId: 'G-96L4S0DLRM',
  );
}
