import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // ANDROID CONFIG
      return const FirebaseOptions(
        apiKey: 'AIzaSyCILo3QNFv8jlVw94T-cD5kSp-VPSw41Pw',
        appId: '1:996871260981:android:31303dbd78327cfcfeda7c',
        messagingSenderId: '996871260981',
        projectId: 'souledspace-c5d3b',
        storageBucket: 'souledspace-c5d3b.firebasestorage.app',
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      // iOS CONFIG
      return const FirebaseOptions(
        apiKey: 'AIzaSyCILo3QNFv8jlVw94T-cD5kSp-VPSw41Pw',
        appId: '1:996871260981:ios:795326c44a0933abfeda7c',
        messagingSenderId: '996871260981',
        projectId: 'souledspace-c5d3b',
        storageBucket: 'souledspace-c5d3b.firebasestorage.app',
      );
    } else {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not supported for this platform.',
      );
    }
  }
}
