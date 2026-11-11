import 'package:chatpilot_app/features/conversations/data/mock_conversations_seed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seed has 4 conversations with messages', () {
    final seed = buildMockConversations();
    expect(seed.length, 4);
    for (final conversation in seed) {
      expect(conversation.messages.length, greaterThanOrEqualTo(3));
    }
  });
}
