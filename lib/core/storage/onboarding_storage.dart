import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorage {
  final SharedPreferences _prefs;

  OnboardingStorage({required SharedPreferences sharedPreferences})
      : _prefs = sharedPreferences;

  static const String _keyHasSeenOnboarding = 'bokku_has_seen_onboarding';

  bool get hasSeenOnboarding => _prefs.getBool(_keyHasSeenOnboarding) ?? false;

  Future<bool> setHasSeenOnboarding([bool value = true]) {
    return _prefs.setBool(_keyHasSeenOnboarding, value);
  }

  Future<bool> clearOnboarding() {
    return _prefs.remove(_keyHasSeenOnboarding);
  }
}
