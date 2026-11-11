import 'package:chatpilot_app/features/settings/presentation/settings_notifier.dart';
import 'package:chatpilot_app/features/voice/data/mock_streaming_stt_engine.dart';
import 'package:chatpilot_app/features/voice/domain/voice_mode.dart';
import 'package:chatpilot_app/features/voice/domain/voice_session_state.dart';
import 'package:chatpilot_app/features/voice/presentation/voice_input_controller.dart';
import 'package:chatpilot_app/features/voice/presentation/voice_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('voice controller streams mock partials and commit keeps text', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
        streamingSttEngineProvider.overrideWithValue(
          MockStreamingSttEngine(
            phrase: '你好世界流式听写',
            charDelay: const Duration(milliseconds: 25),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(sharedPreferencesProvider.future);
    await container
        .read(settingsProvider.notifier)
        .setVoiceMode(VoiceMode.mock);

    final notifier = container.read(voiceInputProvider.notifier);
    await notifier.start();

    await Future<void>.delayed(const Duration(milliseconds: 60));
    final mid = container.read(voiceInputProvider);
    expect(mid.partialText, isNotEmpty);
    expect(
      mid.phase == VoicePhase.listening || mid.phase == VoicePhase.idle,
      isTrue,
    );

    final text = await notifier.commit();
    expect(text, isNotEmpty);
    expect(container.read(voiceInputProvider).phase, VoicePhase.idle);
  });
}
