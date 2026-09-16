import 'package:firebase_core/firebase_core.dart';

import '../config/app_config.dart';
import '../../firebase_options.dart';

enum FirebaseStatus { disabled, ready, failed }

/// Initializes Firebase only when a configured build asks for it.
///
/// This makes the showcase build deterministic and usable offline while
/// keeping one integration point for Auth, Firestore, Functions and Storage.
abstract final class FirebaseBootstrap {
  static FirebaseStatus status = FirebaseStatus.disabled;
  static Object? error;

  static Future<FirebaseStatus> initialize() async {
    final options = DefaultFirebaseOptions.currentPlatform;
    // With the template, options come from dart-defines. After
    // `flutterfire configure`, the generated file supplies these values.
    if ((options.apiKey.isEmpty ||
            options.appId.isEmpty ||
            options.messagingSenderId.isEmpty ||
            options.projectId.isEmpty) &&
        (!AppConfig.firebaseEnabled || !AppConfig.hasFirebaseOptions)) {
      status = FirebaseStatus.disabled;
      return status;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: options,
        );
      }
      status = FirebaseStatus.ready;
    } catch (exception) {
      error = exception;
      status = FirebaseStatus.failed;
    }
    return status;
  }

  static bool get isReady => status == FirebaseStatus.ready;
}
