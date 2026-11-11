import 'dart:ui' show PlatformDispatcher;

import 'package:chatpilot_app/features/settings/data/api_key_provider.dart';
import 'package:chatpilot_app/features/settings/presentation/settings_notifier.dart';
import 'package:chatpilot_app/features/voice/data/auto_streaming_stt_engine.dart';
import 'package:chatpilot_app/features/voice/data/device_streaming_stt_engine.dart';
import 'package:chatpilot_app/features/voice/data/mock_streaming_stt_engine.dart';
import 'package:chatpilot_app/features/voice/data/whisper_stt_engine.dart';
import 'package:chatpilot_app/features/voice/domain/streaming_stt_engine.dart';
import 'package:chatpilot_app/features/voice/domain/voice_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String _mockSttPhrase(Ref ref) {
  final code = resolveAppLanguageCode(
    localePreference: ref.watch(settingsProvider).localePreference,
    platformLocale: PlatformDispatcher.instance.locale,
  );
  return code == 'zh'
      ? '你好，这是 ChatPilot 流式听写演示。'
      : 'Hello, this is the ChatPilot streaming dictation demo.';
}

final streamingSttEngineProvider = Provider<StreamingSttEngine>((ref) {
  final settings = ref.watch(settingsProvider);
  String? readOpenAiKey() => settings.keyFor(ApiKeyProvider.openai);
  final mock = MockStreamingSttEngine(phrase: _mockSttPhrase(ref));

  final engine = switch (settings.voiceMode) {
    VoiceMode.mock => mock,
    VoiceMode.device => DeviceStreamingSttEngine(),
    VoiceMode.whisper => WhisperSttEngine(readApiKey: readOpenAiKey),
    VoiceMode.auto => AutoStreamingSttEngine(
        device: DeviceStreamingSttEngine(),
        whisper: WhisperSttEngine(readApiKey: readOpenAiKey),
      ),
  };

  ref.onDispose(() {
    engine.dispose();
  });

  return engine;
});
