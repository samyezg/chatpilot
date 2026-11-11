import 'dart:convert';

/// Parses Anthropic Messages SSE `data:` lines into text deltas.
Iterable<String> parseClaudeSseDataLine(String line) sync* {
  final trimmed = line.trimRight();
  if (trimmed.isEmpty || trimmed.startsWith(':')) return;
  if (trimmed.startsWith('event:')) return;
  if (!trimmed.startsWith('data:')) return;

  final payload = trimmed.substring(5).trimLeft();
  if (payload.isEmpty) return;

  final decoded = jsonDecode(payload);
  if (decoded is! Map<String, dynamic>) return;

  final type = decoded['type'];
  if (type != 'content_block_delta') return;

  final delta = decoded['delta'];
  if (delta is! Map) return;
  if (delta['type'] != 'text_delta') return;
  final text = delta['text'];
  if (text is String && text.isNotEmpty) {
    yield text;
  }
}
