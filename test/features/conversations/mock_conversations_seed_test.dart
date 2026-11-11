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

  test('zh seed localizes user lines and titles', () {
    final seed = buildMockConversations(languageCode: 'zh');
    expect(seed.first.title, '翻译');
    expect(seed.first.messages.first.content, contains('帮我翻译'));
    // Assistant contrast translation stays English.
    expect(
      seed.first.messages[1].content,
      'The weather is really nice today.',
    );
  });
}
