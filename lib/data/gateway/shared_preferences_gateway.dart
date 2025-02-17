import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesGateway {
  late SharedPreferences _preferences;

  Future<void> clearPreferences() async {
    await _preferences.clear();
  }

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<String>? getFromDisk<T>(String key) async {
    final value = _preferences.get(key);
    return value.toString();
  }

  Future<void> saveToDisk<T>(String key, T value) async {
    if (value is String) {
      await _preferences.setString(key, value);
      return;
    }
    if (value is bool) {
      await _preferences.setBool(key, value);
      return;
    }
    if (value is int) {
      await _preferences.setInt(key, value);
      return;
    }
    if (value is double) {
      await _preferences.setDouble(key, value);
      return;
    }
    if (value is List<String>) {
      await _preferences.setStringList(key, value);
      return;
    }
    throw UnsupportedError('Type $T is not supported by Shared Preferences');
  }
}
