import 'dart:convert';

import 'package:chatpilot_app/features/chat/data/chat_prompt_builder.dart';
import 'package:chatpilot_app/features/chat/data/gemini_sse.dart';
import 'package:chatpilot_app/features/chat/data/openai_compatible_sse.dart';
import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/chat/domain/chat_exception.dart';
import 'package:chatpilot_app/features/chat/domain/chat_repository.dart';
import 'package:chatpilot_app/features/chat/domain/message.dart';
import 'package:http/http.dart' as http;

typedef ApiKeyReader = String? Function();

/// Google Gemini `streamGenerateContent` with SSE (`alt=sse`).
class GeminiChatRepository implements ChatRepository {
  GeminiChatRepository({
    required this.readApiKey,
    http.Client? client,
    this.baseUrl = 'https://generativelanguage.googleapis.com/v1beta',
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null;

  final http.Client _client;
  final ApiKeyReader readApiKey;
  final String baseUrl;
  final bool _ownsClient;

  void dispose() {
    if (_ownsClient) _client.close();
  }

  @override
  Stream<String> sendMessage({
    required AiModel model,
    required String message,
    required String personaId,
    List<Message> history = const [],
  }) async* {
    final apiKey = readApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw const ChatException(
        'Google API key missing. Open Settings and paste your Gemini key.',
      );
    }

    final contents = <Map<String, dynamic>>[
      for (final item in priorTurns(history))
        {
          'role': item.role == MessageRole.user ? 'user' : 'model',
          'parts': [
            {'text': item.content},
          ],
        },
      {
        'role': 'user',
        'parts': [
          {'text': message},
        ],
      },
    ];

    final uri = Uri.parse(
      '$baseUrl/models/${model.apiModelId}:streamGenerateContent',
    ).replace(queryParameters: {'alt': 'sse'});

    final request = http.Request('POST', uri);
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream',
      'x-goog-api-key': apiKey,
    });
    request.body = jsonEncode({
      'systemInstruction': {
        'parts': [
          {'text': systemPromptFor(personaId)},
        ],
      },
      'contents': contents,
    });

    final http.StreamedResponse response;
    try {
      response = await _client.send(request);
    } on Exception catch (error) {
      throw ChatException('Network error calling Gemini: $error');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = await response.stream.bytesToString();
      throw ChatException(_friendlyHttpError(response.statusCode, body));
    }

    var assembled = '';
    final lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lines) {
      for (final delta in parseGeminiSseDataLine(line)) {
        assembled = accumulatePrefix(assembled, delta);
        yield assembled;
      }
    }

    if (assembled.trim().isEmpty) {
      throw const ChatException('Gemini returned an empty response.');
    }
  }

  String _friendlyHttpError(int statusCode, String body) {
    var detail = body.trim();
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final error = decoded['error'];
        if (error is Map && error['message'] is String) {
          detail = error['message'] as String;
        }
      }
    } catch (_) {}

    if (statusCode == 401 || statusCode == 403) {
      return 'Google rejected the API key. Check Settings.';
    }
    if (statusCode == 429) {
      return 'Gemini rate limit hit. Try again shortly.';
    }
    return 'Gemini error ($statusCode): $detail';
  }
}
