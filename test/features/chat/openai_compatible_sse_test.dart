import 'package:chatpilot_app/features/chat/data/openai_compatible_sse.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses OpenAI-compatible SSE deltas', () {
    final deltas = parseSseDataLine(
      'data: {"choices":[{"delta":{"content":"Hel"}}]}',
    ).toList();
    expect(deltas, ['Hel']);

    expect(parseSseDataLine('data: [DONE]').toList(), isEmpty);
    expect(parseSseDataLine(': keep-alive').toList(), isEmpty);
  });

  test('accumulates streaming prefixes', () {
    expect(accumulatePrefix('Hel', 'lo'), 'Hello');
  });
}
