import 'package:chatpilot_app/features/voice/data/auto_streaming_stt_engine.dart';
import 'package:chatpilot_app/features/voice/data/device_streaming_stt_engine.dart';
import 'package:chatpilot_app/features/voice/data/whisper_stt_engine.dart';
import 'package:chatpilot_app/features/voice/domain/voice_exception.dart';
import 'package:flutter_test/flutter_test.dart';

class _UnavailableDevice extends DeviceStreamingSttEngine {
  @override
  Future<bool> isAvailable() async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('auto never falls back to mock when device and whisper unavailable', () async {
    final engine = AutoStreamingSttEngine(
      device: _UnavailableDevice(),
      whisper: WhisperSttEngine(readApiKey: () => null),
    );

    await expectLater(
      engine.start().toList(),
      throwsA(isA<VoiceException>()),
    );
  });
}
