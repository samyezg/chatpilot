import 'package:chatpilot_app/features/voice/data/device_streaming_stt_engine.dart';
import 'package:chatpilot_app/features/voice/data/whisper_stt_engine.dart';
import 'package:chatpilot_app/features/voice/domain/stt_update.dart';
import 'package:chatpilot_app/features/voice/domain/streaming_stt_engine.dart';
import 'package:chatpilot_app/features/voice/domain/voice_exception.dart';

/// Resolves Device → Whisper at [start] time.
///
/// Never falls back to Mock — policy: no silent fake dictation.
class AutoStreamingSttEngine implements StreamingSttEngine {
  AutoStreamingSttEngine({
    required this.device,
    required this.whisper,
  });

  final DeviceStreamingSttEngine device;
  final WhisperSttEngine whisper;

  StreamingSttEngine? _active;

  @override
  String get label => _active?.label ?? 'Auto';

  @override
  Future<bool> isAvailable() async {
    if (await device.isAvailable()) return true;
    return whisper.isAvailable();
  }

  Future<StreamingSttEngine> _pick() async {
    if (await device.isAvailable()) return device;
    if (await whisper.isAvailable()) return whisper;
    throw const VoiceException(
      'No real speech engine available. Enable Device STT permissions, '
      'add an OpenAI key for Whisper, or explicitly choose Mock (demo) '
      'in Settings.',
    );
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
  }
}
