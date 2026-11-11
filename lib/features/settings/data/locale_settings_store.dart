import 'package:shared_preferences/shared_preferences.dart';

/// Persisted UI language preference.
///
/// Empty string means follow the system language (resolved at runtime with
/// English fallback when the system locale is neither `en` nor `zh`).
class LocaleSettingsStore {
  LocaleSettingsStore(this._prefs);

  static const prefsKey = 'app_locale';

  final SharedPreferences _prefs;

  /// `''` = system, otherwise `en` / `zh`.
  String getPreference() => _prefs.getString(prefsKey) ?? '';

  Future<void> setPreference(String value) async {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      await _prefs.remove(prefsKey);
      return;
    }
    await _prefs.setString(prefsKey, normalized);
  }
}
