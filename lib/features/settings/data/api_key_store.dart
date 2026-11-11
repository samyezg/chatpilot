import 'package:chatpilot_app/features/settings/data/api_key_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyStore {
  ApiKeyStore(this._prefs);

  final SharedPreferences _prefs;

  String? getKey(ApiKeyProvider provider) {
    final value = _prefs.getString(provider.prefsKey);
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  Future<void> setKey(ApiKeyProvider provider, String? value) async {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      await _prefs.remove(provider.prefsKey);
      return;
    }
    await _prefs.setString(provider.prefsKey, trimmed);
  }

  /// Legacy helpers kept for call-site clarity.
  String? getDeepSeekKey() => getKey(ApiKeyProvider.deepseek);

  Future<void> setDeepSeekKey(String? value) =>
      setKey(ApiKeyProvider.deepseek, value);
}
