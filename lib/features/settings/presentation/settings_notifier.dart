import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/settings/data/api_key_provider.dart';
import 'package:chatpilot_app/features/settings/data/api_key_store.dart';
import 'package:chatpilot_app/features/settings/data/locale_settings_store.dart';
import 'package:chatpilot_app/features/settings/data/voice_settings_store.dart';
import 'package:chatpilot_app/features/voice/domain/voice_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  const SettingsState({
    this.keys = const {},
    this.voiceMode = VoiceMode.device,
    this.localePreference = '',
  });

  final Map<ApiKeyProvider, String> keys;
  final VoiceMode voiceMode;

  /// `''` = follow system; `en` / `zh` = manual override.
  final String localePreference;

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

  /// Explicit locale when user locked language; null means follow system.
  Locale? get materialLocale {
    final code = localePreference.trim();
    if (code.isEmpty) return null;
    return Locale(code);
  }

  SettingsState copyWith({
    Map<ApiKeyProvider, String>? keys,
    VoiceMode? voiceMode,
    String? localePreference,
  }) {
    return SettingsState(
      keys: keys ?? this.keys,
      voiceMode: voiceMode ?? this.voiceMode,
      localePreference: localePreference ?? this.localePreference,
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

final localeSettingsStoreProvider = Provider<LocaleSettingsStore?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).asData?.value;
  if (prefs == null) return null;
  return LocaleSettingsStore(prefs);
});

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final store = ref.watch(apiKeyStoreProvider);
    final voiceStore = ref.watch(voiceSettingsStoreProvider);
    final localeStore = ref.watch(localeSettingsStoreProvider);
    final localePreference = localeStore?.getPreference() ?? '';
    if (store == null) {
      return SettingsState(
        voiceMode: voiceStore?.getMode() ?? VoiceMode.device,
        localePreference: localePreference,
      );
    }
    final keys = <ApiKeyProvider, String>{};
    for (final provider in ApiKeyProvider.values) {
      final value = store.getKey(provider);
      if (value != null) keys[provider] = value;
    }
    return SettingsState(
      keys: keys,
      voiceMode: voiceStore?.getMode() ?? VoiceMode.device,
      localePreference: localePreference,
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

  /// Pass `''` / null to follow system; `en` or `zh` to lock.
  Future<void> setLocalePreference(String? preference) async {
    final normalized = (preference ?? '').trim();
    final store = ref.read(localeSettingsStoreProvider);
    if (store != null) await store.setPreference(normalized);
    state = state.copyWith(localePreference: normalized);
  }

  Future<void> saveDeepSeekKey(String value) =>
      saveKey(ApiKeyProvider.deepseek, value);

  Future<void> clearDeepSeekKey() => clearKey(ApiKeyProvider.deepseek);
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

/// Resolve UI language code for seeds / non-widget callers.
String resolveAppLanguageCode({
  required String localePreference,
  required Locale platformLocale,
}) {
  final manual = localePreference.trim();
  if (manual == 'en' || manual == 'zh') return manual;
  final primary = platformLocale.languageCode.toLowerCase();
  if (primary.startsWith('zh')) return 'zh';
  if (primary.startsWith('en')) return 'en';
  return 'en';
}
