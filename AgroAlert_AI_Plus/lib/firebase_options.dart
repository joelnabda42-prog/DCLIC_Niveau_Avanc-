import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web non supporté');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Plateforme non supportée');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAIMe7u9ZfiA9rYi0Dl_NmqoSp1rwV-t24',
    appId: '1:136136692261:android:7f0d7930eaf338000265cc',
    messagingSenderId: '136136692261',
    projectId: 'agroalert-ai-plus',
    storageBucket: 'agroalert-ai-plus.firebasestorage.app',
  );
}