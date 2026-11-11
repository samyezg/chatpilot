import 'dart:convert';

/// Parses Gemini `streamGenerateContent?alt=sse` data lines into text deltas.
Iterable<String> parseGeminiSseDataLine(String line) sync* {
  final trimmed = line.trimRight();
  if (trimmed.isEmpty || trimmed.startsWith(':')) return;
  if (!trimmed.startsWith('data:')) return;

  final payload = trimmed.substring(5).trimLeft();
  if (payload.isEmpty || payload == '[DONE]') return;

  final decoded = jsonDecode(payload);
  if (decoded is! Map<String, dynamic>) return;

  final candidates = decoded['candidates'];
  if (candidates is! List || candidates.isEmpty) return;
  final first = candidates.first;
  if (first is! Map) return;
  final content = first['content'];
  if (content is! Map) return;
  final parts = content['parts'];
  if (parts is! List) return;

  final buffer = StringBuffer();
  for (final part in parts) {
    if (part is Map && part['text'] is String) {
      final text = part['text'] as String;
      if (text.isNotEmpty) buffer.write(text);
    }
  }
  final text = buffer.toString();
  if (text.isNotEmpty) yield text;
}
