import 'package:chatpilot_app/features/voice/domain/voice_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VoiceSettingsStore {
  VoiceSettingsStore(this._prefs);

  static const modeKey = 'voice_mode';

  final SharedPreferences _prefs;

  VoiceMode getMode() {
    final raw = _prefs.getString(modeKey);
    if (raw == null || raw.isEmpty) return VoiceMode.device;
    return VoiceMode.values.firstWhere(
      (mode) => mode.name == raw,
      orElse: () => VoiceMode.device,
    );
  }

  Future<void> setMode(VoiceMode mode) async {
    await _prefs.setString(modeKey, mode.name);
  }
}
