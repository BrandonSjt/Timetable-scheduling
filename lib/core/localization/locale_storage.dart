import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LocaleStorage {
  Future<String?> readLocaleTag();

  Future<void> writeLocaleTag(String tag);
}

class SharedPreferencesLocaleStorage implements LocaleStorage {
  SharedPreferencesLocaleStorage(this._preferences);

  static const String preferenceKey = 'app_locale';

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> readLocaleTag() => _preferences.getString(preferenceKey);

  @override
  Future<void> writeLocaleTag(String tag) =>
      _preferences.setString(preferenceKey, tag);
}
