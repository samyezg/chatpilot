import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/settings/data/api_key_provider.dart';
import 'package:chatpilot_app/features/settings/data/api_key_store.dart';
import 'package:chatpilot_app/features/settings/data/voice_settings_store.dart';
import 'package:chatpilot_app/features/voice/domain/voice_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  const SettingsState({
    this.keys = const {},
    this.voiceMode = VoiceMode.auto,
  });

  final Map<ApiKeyProvider, String> keys;
  final VoiceMode voiceMode;

  String? keyFor(ApiKeyProvider provider) => keys[provider];

  bool hasKey(ApiKeyProvider provider) {
    final value = keys[provider];
    return value != null && value.trim().isNotEmpty;
  }

  bool hasKeyForModel(AiModel model) {
    final provider = model.apiKeyProvider;
    if (provider == null) return true;
    return hasKey(provider);
  }

  /// Back-compat for older call sites / tests.
  String? get deepSeekApiKey => keyFor(ApiKeyProvider.deepseek);

  bool get hasDeepSeekKey => hasKey(ApiKeyProvider.deepseek);

  SettingsState copyWith({
    Map<ApiKeyProvider, String>? keys,
    VoiceMode? voiceMode,
  }) {
    return SettingsState(
      keys: keys ?? this.keys,
      voiceMode: voiceMode ?? this.voiceMode,
    );
  }

  SettingsState copyWithKey(ApiKeyProvider provider, String? value) {
    final next = Map<ApiKeyProvider, String>.from(keys);
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      next.remove(provider);
    } else {
      next[provider] = trimmed;
    }
    return copyWith(keys: next);
  }
}

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final apiKeyStoreProvider = Provider<ApiKeyStore?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).asData?.value;
  if (prefs == null) return null;
  return ApiKeyStore(prefs);
});

final voiceSettingsStoreProvider = Provider<VoiceSettingsStore?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).asData?.value;
  if (prefs == null) return null;
  return VoiceSettingsStore(prefs);
});

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final store = ref.watch(apiKeyStoreProvider);
    final voiceStore = ref.watch(voiceSettingsStoreProvider);
    if (store == null) {
      return SettingsState(voiceMode: voiceStore?.getMode() ?? VoiceMode.auto);
    }
    final keys = <ApiKeyProvider, String>{};
    for (final provider in ApiKeyProvider.values) {
      final value = store.getKey(provider);
      if (value != null) keys[provider] = value;
    }
    return SettingsState(
      keys: keys,
      voiceMode: voiceStore?.getMode() ?? VoiceMode.auto,
    );
  }

  Future<void> saveKey(ApiKeyProvider provider, String value) async {
    final store = ref.read(apiKeyStoreProvider);
    if (store == null) return;
    await store.setKey(provider, value);
    state = state.copyWithKey(provider, store.getKey(provider));
  }

  Future<void> clearKey(ApiKeyProvider provider) async {
    final store = ref.read(apiKeyStoreProvider);
    if (store == null) return;
    await store.setKey(provider, null);
    state = state.copyWithKey(provider, null);
  }

  Future<void> setVoiceMode(VoiceMode mode) async {
    final store = ref.read(voiceSettingsStoreProvider);
    if (store != null) await store.setMode(mode);
    state = state.copyWith(voiceMode: mode);
  }

  Future<void> saveDeepSeekKey(String value) =>
      saveKey(ApiKeyProvider.deepseek, value);

  Future<void> clearDeepSeekKey() => clearKey(ApiKeyProvider.deepseek);
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
