import 'package:chatpilot_app/features/settings/data/api_key_provider.dart';
import 'package:chatpilot_app/features/settings/presentation/settings_notifier.dart';
import 'package:chatpilot_app/features/voice/data/auto_streaming_stt_engine.dart';
import 'package:chatpilot_app/features/voice/data/device_streaming_stt_engine.dart';
import 'package:chatpilot_app/features/voice/data/mock_streaming_stt_engine.dart';
import 'package:chatpilot_app/features/voice/data/whisper_stt_engine.dart';
import 'package:chatpilot_app/features/voice/domain/streaming_stt_engine.dart';
import 'package:chatpilot_app/features/voice/domain/voice_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final streamingSttEngineProvider = Provider<StreamingSttEngine>((ref) {
  final settings = ref.watch(settingsProvider);
  String? readOpenAiKey() => settings.keyFor(ApiKeyProvider.openai);

  final engine = switch (settings.voiceMode) {
    VoiceMode.mock => MockStreamingSttEngine(),
    VoiceMode.device => DeviceStreamingSttEngine(),
    VoiceMode.whisper => WhisperSttEngine(readApiKey: readOpenAiKey),
    VoiceMode.auto => AutoStreamingSttEngine(
        device: DeviceStreamingSttEngine(),
        whisper: WhisperSttEngine(readApiKey: readOpenAiKey),
        mock: MockStreamingSttEngine(),
      ),
  };

  ref.onDispose(() {
    engine.dispose();
  });

  return engine;
});
