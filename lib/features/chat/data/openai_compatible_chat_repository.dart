import 'dart:convert';

import 'package:chatpilot_app/features/chat/data/chat_prompt_builder.dart';
import 'package:chatpilot_app/features/chat/data/openai_compatible_sse.dart';
import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/chat/domain/chat_exception.dart';
import 'package:chatpilot_app/features/chat/domain/chat_repository.dart';
import 'package:chatpilot_app/features/chat/domain/message.dart';
import 'package:http/http.dart' as http;

typedef ApiKeyReader = String? Function();

/// OpenAI Chat Completions SSE — also used by DeepSeek and other compat APIs.
class OpenAiCompatibleChatRepository implements ChatRepository {
  OpenAiCompatibleChatRepository({
    required this.readApiKey,
    required this.providerName,
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null;

  final http.Client _client;
  final ApiKeyReader readApiKey;
  final String providerName;
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
      throw ChatException(
        '$providerName API key missing. Open Settings and paste your key.',
      );
    }

    final request = http.Request(
      'POST',
      Uri.parse('$baseUrl/chat/completions'),
    );
    request.headers.addAll({
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream',
    });
    request.body = jsonEncode({
      'model': model.apiModelId,
      'messages': openAiStyleMessages(
        personaId: personaId,
        message: message,
        history: history,
      ),
      'stream': true,
    });

    final http.StreamedResponse response;
    try {
      response = await _client.send(request);
    } on Exception catch (error) {
      throw ChatException('Network error calling $providerName: $error');
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
      for (final delta in parseSseDataLine(line)) {
        assembled = accumulatePrefix(assembled, delta);
        yield assembled;
      }
    }

    if (assembled.trim().isEmpty) {
      throw ChatException('$providerName returned an empty response.');
    }
  }

  String _friendlyHttpError(int statusCode, String body) {
    var detail = body.trim();
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['error'] is Map) {
        final message = decoded['error']['message'];
        if (message is String && message.isNotEmpty) detail = message;
      }
    } catch (_) {}

    if (statusCode == 401 || statusCode == 403) {
      return '$providerName rejected the API key. Check Settings.';
    }
    if (statusCode == 429) {
      return '$providerName rate limit hit. Try again shortly.';
    }
    return '$providerName error ($statusCode): $detail';
  }
}
