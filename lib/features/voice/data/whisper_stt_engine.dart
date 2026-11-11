import 'dart:async';
import 'dart:convert';

import 'package:chatpilot_app/features/chat/data/openai_compatible_chat_repository.dart';
import 'package:chatpilot_app/features/voice/data/file_delete_io.dart'
    if (dart.library.html) 'package:chatpilot_app/features/voice/data/file_delete_stub.dart';
import 'package:chatpilot_app/features/voice/domain/stt_update.dart';
import 'package:chatpilot_app/features/voice/domain/streaming_stt_engine.dart';
import 'package:chatpilot_app/features/voice/domain/voice_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Record audio, then transcribe with OpenAI Whisper.
///
/// While listening, emits lightweight partials (`…`) so the UI can show
/// streaming presence; the final transcript arrives after [stop].
class WhisperSttEngine implements StreamingSttEngine {
  WhisperSttEngine({
    required this.readApiKey,
    AudioRecorder? recorder,
    http.Client? client,
    this.baseUrl = 'https://api.openai.com/v1',
  }) : _recorder = recorder ?? AudioRecorder(),
       _client = client ?? http.Client(),
       _ownsClient = client == null,
       _ownsRecorder = recorder == null;

  final ApiKeyReader readApiKey;
  final AudioRecorder _recorder;
  final http.Client _client;
  final String baseUrl;
  final bool _ownsClient;
  final bool _ownsRecorder;

  StreamController<SttUpdate>? _controller;
  Timer? _pulse;
  String? _path;
  var _stopping = false;

  @override
  String get label => 'OpenAI Whisper';

  @override
  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    final key = readApiKey();
    if (key == null || key.isEmpty) return false;
    return _recorder.hasPermission();
  }

  @override
  Stream<SttUpdate> start({String? localeId}) async* {
    if (kIsWeb) {
      throw const VoiceException(
        'Whisper recording is not wired for Web — use Device STT or Mock.',
      );
    }
    final apiKey = readApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw const VoiceException(
        'OpenAI API key missing for Whisper. Add it in Settings.',
      );
    }
    if (!await _recorder.hasPermission()) {
      throw const VoiceException('Microphone permission denied.');
    }

    await cancel();
    _stopping = false;
    final dir = await getTemporaryDirectory();
    _path = p.join(
      dir.path,
      'chatpilot_voice_${DateTime.now().millisecondsSinceEpoch}.wav',
    );

    final controller = StreamController<SttUpdate>();
    _controller = controller;

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        numChannels: 1,
        sampleRate: 16000,
      ),
      path: _path!,
    );

    var dots = 0;
    _pulse = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (controller.isClosed || _stopping) return;
      dots = (dots % 3) + 1;
      controller.add(SttUpdate(text: '…' * dots, isFinal: false));
    });

    yield* controller.stream;
  }

  @override
  Future<void> stop() async {
    if (_stopping) return;
    _stopping = true;
    _pulse?.cancel();

    final controller = _controller;
    final path = await _recorder.stop() ?? _path;
    if (controller == null) return;

    if (path == null || path.isEmpty) {
      if (!controller.isClosed) {
        controller.addError(const VoiceException('No audio captured.'));
        await controller.close();
      }
      return;
    }

    if (!controller.isClosed) {
      controller.add(const SttUpdate(text: 'Transcribing…', isFinal: false));
    }

    try {
      final text = await _transcribe(path);
      if (!controller.isClosed) {
        controller.add(SttUpdate(text: text, isFinal: true));
      }
    } catch (error) {
      if (!controller.isClosed) {
        controller.addError(error);
      }
    } finally {
      await deletePathIfExists(path);
      if (!controller.isClosed) {
        await controller.close();
      }
    }
  }

  Future<String> _transcribe(String path) async {
    final apiKey = readApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw const VoiceException('OpenAI API key missing for Whisper.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/audio/transcriptions'),
    );
    request.headers['Authorization'] = 'Bearer $apiKey';
    request.fields['model'] = 'whisper-1';
    request.files.add(await http.MultipartFile.fromPath('file', path));

    final streamed = await _client.send(request);
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      var detail = body.trim();
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map && decoded['error'] is Map) {
          final message = decoded['error']['message'];
          if (message is String && message.isNotEmpty) detail = message;
        }
      } catch (_) {}
      throw VoiceException('Whisper error (${streamed.statusCode}): $detail');
    }

    final decoded = jsonDecode(body);
    if (decoded is Map && decoded['text'] is String) {
      final text = (decoded['text'] as String).trim();
      if (text.isEmpty) {
        throw const VoiceException('Whisper returned empty text.');
      }
      return text;
    }
    throw const VoiceException('Unexpected Whisper response.');
  }

  @override
  Future<void> cancel() async {
    _pulse?.cancel();
    _stopping = true;
    try {
      if (await _recorder.isRecording()) {
        await _recorder.cancel();
      }
    } catch (_) {}
    final path = _path;
    _path = null;
    if (path != null) await deletePathIfExists(path);
    final controller = _controller;
    _controller = null;
    if (controller != null && !controller.isClosed) {
      await controller.close();
    }
  }

  @override
  Future<void> dispose() async {
    await cancel();
    if (_ownsRecorder) await _recorder.dispose();
    if (_ownsClient) _client.close();
  }
}
