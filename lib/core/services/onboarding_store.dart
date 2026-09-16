import 'package:shared_preferences/shared_preferences.dart';

abstract final class OnboardingStore {
  static const _completedKey = 'onboarding_completed_v1';

  static Future<bool> hasCompleted() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_completedKey) ?? false;
  }

  static Future<void> markCompleted() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_completedKey, true);
  }

  static Future<void> reset() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_completedKey);
  }
}
