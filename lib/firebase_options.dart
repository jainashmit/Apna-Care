// Generated from the Android Firebase app registered for ApnaCare.
// These identifiers are intended for client apps; restrict the API key in
// Google Cloud Console before publishing the application.
import 'package:firebase_core/firebase_core.dart';

import 'core/config/app_config.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    final configured = AppConfig.firebaseApiKey.isNotEmpty &&
        AppConfig.firebaseAppId.isNotEmpty &&
        AppConfig.firebaseProjectId.isNotEmpty;
    if (configured) {
      return FirebaseOptions(
        apiKey: AppConfig.firebaseApiKey,
        appId: AppConfig.firebaseAppId,
        messagingSenderId: AppConfig.firebaseMessagingSenderId,
        projectId: AppConfig.firebaseProjectId,
        storageBucket: AppConfig.firebaseStorageBucket.isEmpty
            ? null
            : AppConfig.firebaseStorageBucket,
        authDomain: AppConfig.firebaseAuthDomain.isEmpty
            ? null
            : AppConfig.firebaseAuthDomain,
      );
    }

    return const FirebaseOptions(
      apiKey: 'AIzaSyACjo00ynArTYuyQxLToVOSHIuQ_jNokz4',
      appId: '1:151121631235:android:0198e32f3668d136c2d636',
      messagingSenderId: '151121631235',
      projectId: 'apna-care-abee7',
      storageBucket: 'apna-care-abee7.firebasestorage.app',
    );
  }
}
