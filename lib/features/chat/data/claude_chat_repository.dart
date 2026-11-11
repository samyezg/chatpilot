import 'dart:convert';

import 'package:chatpilot_app/features/chat/data/chat_prompt_builder.dart';
import 'package:chatpilot_app/features/chat/data/claude_sse.dart';
import 'package:chatpilot_app/features/chat/data/openai_compatible_sse.dart';
import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/chat/domain/chat_exception.dart';
import 'package:chatpilot_app/features/chat/domain/chat_repository.dart';
import 'package:chatpilot_app/features/chat/domain/message.dart';
import 'package:http/http.dart' as http;

typedef ApiKeyReader = String? Function();

/// Anthropic Messages API with SSE streaming.
class ClaudeChatRepository implements ChatRepository {
  ClaudeChatRepository({
    required this.readApiKey,
    http.Client? client,
    this.baseUrl = 'https://api.anthropic.com',
    this.anthropicVersion = '2023-06-01',
    this.maxTokens = 4096,
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null;

  final http.Client _client;
  final ApiKeyReader readApiKey;
  final String baseUrl;
  final String anthropicVersion;
  final int maxTokens;
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
        'Anthropic API key missing. Open Settings and paste your key.',
      );
    }

    final messages = <Map<String, String>>[
      for (final item in priorTurns(history))
        {
          'role': item.role == MessageRole.user ? 'user' : 'assistant',
          'content': item.content,
        },
      {'role': 'user', 'content': message},
    ];

    final request = http.Request(
      'POST',
      Uri.parse('$baseUrl/v1/messages'),
    );
    request.headers.addAll({
      'x-api-key': apiKey,
      'anthropic-version': anthropicVersion,
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream',
    });
    request.body = jsonEncode({
      'model': model.apiModelId,
      'max_tokens': maxTokens,
      'system': systemPromptFor(personaId),
      'messages': messages,
      'stream': true,
    });

    final http.StreamedResponse response;
    try {
      response = await _client.send(request);
    } on Exception catch (error) {
      throw ChatException('Network error calling Anthropic: $error');
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
      for (final delta in parseClaudeSseDataLine(line)) {
        assembled = accumulatePrefix(assembled, delta);
        yield assembled;
      }
    }

    if (assembled.trim().isEmpty) {
      throw const ChatException('Anthropic returned an empty response.');
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
        } else if (decoded['message'] is String) {
          detail = decoded['message'] as String;
        }
      }
    } catch (_) {}

    if (statusCode == 401 || statusCode == 403) {
      return 'Anthropic rejected the API key. Check Settings.';
    }
    if (statusCode == 429) {
      return 'Anthropic rate limit hit. Try again shortly.';
    }
    return 'Anthropic error ($statusCode): $detail';
  }
}
