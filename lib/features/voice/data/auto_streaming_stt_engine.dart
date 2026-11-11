import 'package:chatpilot_app/features/voice/data/device_streaming_stt_engine.dart';
import 'package:chatpilot_app/features/voice/data/mock_streaming_stt_engine.dart';
import 'package:chatpilot_app/features/voice/data/whisper_stt_engine.dart';
import 'package:chatpilot_app/features/voice/domain/stt_update.dart';
import 'package:chatpilot_app/features/voice/domain/streaming_stt_engine.dart';
import 'package:chatpilot_app/features/voice/domain/voice_exception.dart';

/// Resolves Device → Whisper → Mock at [start] time.
class AutoStreamingSttEngine implements StreamingSttEngine {
  AutoStreamingSttEngine({
    required this.device,
    required this.whisper,
    required this.mock,
  });

  final DeviceStreamingSttEngine device;
  final WhisperSttEngine whisper;
  final MockStreamingSttEngine mock;

  StreamingSttEngine? _active;

  @override
  String get label => _active?.label ?? 'Auto';

  @override
  Future<bool> isAvailable() async => true;

  Future<StreamingSttEngine> _pick() async {
    if (await device.isAvailable()) return device;
    if (await whisper.isAvailable()) return whisper;
    return mock;
  }

  @override
  Stream<SttUpdate> start({String? localeId}) async* {
    final engine = await _pick();
    _active = engine;
    yield* engine.start(localeId: localeId);
  }

  @override
  Future<void> stop() async {
    final engine = _active;
    if (engine == null) {
      throw const VoiceException('Voice session is not active.');
    }
    await engine.stop();
  }

  @override
  Future<void> cancel() async {
    await _active?.cancel();
  }

  @override
  Future<void> dispose() async {
    await device.dispose();
    await whisper.dispose();
    await mock.dispose();
  }
}
