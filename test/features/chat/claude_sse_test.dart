import 'package:chatpilot_app/features/chat/data/claude_sse.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses Anthropic content_block_delta text', () {
    final deltas = parseClaudeSseDataLine(
      'data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hi"}}',
    ).toList();
    expect(deltas, ['Hi']);

    expect(
      parseClaudeSseDataLine('event: content_block_delta').toList(),
      isEmpty,
    );
    expect(
      parseClaudeSseDataLine(
        'data: {"type":"message_stop"}',
      ).toList(),
      isEmpty,
    );
  });
}
