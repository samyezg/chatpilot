import 'dart:async';

import 'package:chatpilot_app/features/voice/domain/stt_update.dart';
import 'package:chatpilot_app/features/voice/domain/streaming_stt_engine.dart';

/// Offline demo — streams a canned phrase as growing prefixes.
class MockStreamingSttEngine implements StreamingSttEngine {
  MockStreamingSttEngine({
    this.phrase = 'Hello, this is the ChatPilot streaming dictation demo.',
    this.charDelay = const Duration(milliseconds: 45),
  });

  final String phrase;
  final Duration charDelay;

  StreamController<SttUpdate>? _controller;
  Timer? _timer;
  var _index = 0;
  var _cancelled = false;

  @override
  String get label => 'Mock';

  @override
  Future<bool> isAvailable() async => true;

  @override
  Stream<SttUpdate> start({String? localeId}) {
    _cancelled = false;
    _index = 0;
    _timer?.cancel();
    _controller?.close();
    final controller = StreamController<SttUpdate>();
    _controller = controller;

    _timer = Timer.periodic(charDelay, (timer) {
      if (_cancelled || controller.isClosed) {
        timer.cancel();
        return;
      }
      _index += 1;
      if (_index >= phrase.length) {
        timer.cancel();
        controller.add(SttUpdate(text: phrase, isFinal: true));
        unawaited(controller.close());
        return;
      }
      controller.add(
        SttUpdate(text: phrase.substring(0, _index), isFinal: false),
      );
    });

    return controller.stream;
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    final controller = _controller;
    if (controller == null || controller.isClosed) return;
    final text = _index <= 0
        ? phrase
        : phrase.substring(0, _index.clamp(0, phrase.length));
    controller.add(SttUpdate(text: text, isFinal: true));
    await controller.close();
  }

  @override
  Future<void> cancel() async {
    _cancelled = true;
    _timer?.cancel();
    await _controller?.close();
  }

  @override
  Future<void> dispose() => cancel();
}
