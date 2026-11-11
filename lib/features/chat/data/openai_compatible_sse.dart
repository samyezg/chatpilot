import 'dart:convert';

/// Parses OpenAI-compatible chat.completion.chunk SSE payloads.
/// Yields incremental **delta** strings (not full prefixes).
Iterable<String> parseSseDataLine(String line) sync* {
  final trimmed = line.trimRight();
  if (trimmed.isEmpty || trimmed.startsWith(':')) return;
  if (!trimmed.startsWith('data:')) return;

  final payload = trimmed.substring(5).trimLeft();
  if (payload.isEmpty || payload == '[DONE]') return;

  final decoded = jsonDecode(payload);
  if (decoded is! Map<String, dynamic>) return;

  final choices = decoded['choices'];
  if (choices is! List || choices.isEmpty) return;
  final first = choices.first;
  if (first is! Map) return;
  final delta = first['delta'];
  if (delta is! Map) return;
  final content = delta['content'];
  if (content is String && content.isNotEmpty) {
    yield content;
  }
}

String accumulatePrefix(String current, String delta) => current + delta;
