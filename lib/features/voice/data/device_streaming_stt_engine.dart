import 'dart:async';

import 'package:chatpilot_app/features/voice/domain/stt_update.dart';
import 'package:chatpilot_app/features/voice/domain/streaming_stt_engine.dart';
import 'package:chatpilot_app/features/voice/domain/voice_exception.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Platform speech recognition with live partial results.
class DeviceStreamingSttEngine implements StreamingSttEngine {
  DeviceStreamingSttEngine({SpeechToText? speech})
      : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  StreamController<SttUpdate>? _controller;
  var _initialized = false;
  var _available = false;

  @override
  String get label => 'Device STT';

  @override
  Future<bool> isAvailable() async {
    await _ensureInit();
    return _available;
  }

  Future<void> _ensureInit() async {
    if (_initialized) return;
    _available = await _speech.initialize(
      onError: (error) {
        final controller = _controller;
        if (controller == null || controller.isClosed) return;
        controller.addError(VoiceException(error.errorMsg));
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          final controller = _controller;
          if (controller == null || controller.isClosed) return;
          scheduleMicrotask(() {
            if (!controller.isClosed) unawaited(controller.close());
          });
        }
      },
    );
    _initialized = true;
  }

  @override
  Stream<SttUpdate> start({String? localeId}) async* {
    await _ensureInit();
    if (!_available) {
      throw const VoiceException(
        'Device speech recognition is unavailable on this platform.',
      );
    }

    await _speech.stop();
    final controller = StreamController<SttUpdate>();
    _controller = controller;

    unawaited(
      _speech
          .listen(
            onResult: (result) {
              if (controller.isClosed) return;
              controller.add(
                SttUpdate(
                  text: result.recognizedWords,
                  isFinal: result.finalResult,
                ),
              );
              if (result.finalResult && !controller.isClosed) {
                unawaited(controller.close());
              }
            },
            listenOptions: SpeechListenOptions(
              partialResults: true,
              cancelOnError: true,
              listenMode: ListenMode.dictation,
              localeId: localeId,
            ),
          )
          .catchError((Object error, StackTrace stack) {
            if (!controller.isClosed) {
              controller.addError(error, stack);
              unawaited(controller.close());
            }
            return false;
          }),
    );

    yield* controller.stream;
  }

  @override
  Future<void> stop() async {
    // Let the platform flush a final result before the status callback closes.
    await _speech.stop();
  }

  @override
  Future<void> cancel() async {
    await _speech.cancel();
    final controller = _controller;
    if (controller != null && !controller.isClosed) {
      await controller.close();
    }
  }

  @override
  Future<void> dispose() async {
    await cancel();
  }
}
