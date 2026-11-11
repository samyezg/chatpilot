import 'package:chatpilot_app/features/chat/data/gemini_sse.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses Gemini SSE candidate parts', () {
    final deltas = parseGeminiSseDataLine(
      'data: {"candidates":[{"content":{"parts":[{"text":"Hel"}],"role":"model"}}]}',
    ).toList();
    expect(deltas, ['Hel']);

    expect(parseGeminiSseDataLine('data: [DONE]').toList(), isEmpty);
    expect(parseGeminiSseDataLine(': keep-alive').toList(), isEmpty);
  });
}
