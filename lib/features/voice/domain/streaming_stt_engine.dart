import 'package:chatpilot_app/features/voice/domain/stt_update.dart';

/// Cross-platform streaming speech-to-text contract.
abstract class StreamingSttEngine {
  String get label;

  Future<bool> isAvailable();

  /// Starts listening and yields partial / final transcript updates.
  Stream<SttUpdate> start({String? localeId});

  /// Stops capture and allows a final update to flush.
  Future<void> stop();

  /// Aborts without committing (best-effort).
  Future<void> cancel();

  Future<void> dispose();
}
