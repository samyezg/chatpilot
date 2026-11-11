import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/chat/domain/message.dart';
import 'package:chatpilot_app/features/conversations/data/conversation_codec.dart';
import 'package:chatpilot_app/features/conversations/domain/conversation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trips conversations JSON', () {
    final original = Conversation(
      id: 'c1',
      title: 'Hello',
      model: AiModel.deepseek,
      personaId: 'general',
      createdAt: DateTime.utc(2026, 11, 10),
      updatedAt: DateTime.utc(2026, 11, 10, 1),
      messages: [
        Message(
          id: 'm1',
          role: MessageRole.user,
          content: 'hi',
          createdAt: DateTime.utc(2026, 11, 10),
        ),
      ],
    );

    final encoded = ConversationCodec.encodeList([original]);
    final decoded = ConversationCodec.decodeList(encoded).single;

    expect(decoded.id, original.id);
    expect(decoded.title, original.title);
    expect(decoded.model, AiModel.deepseek);
    expect(decoded.messages.single.content, 'hi');
  });

  test('titleFromFirstMessage truncates', () {
    expect(ConversationCodec.titleFromFirstMessage('short'), 'short');
    expect(
      ConversationCodec.titleFromFirstMessage('a' * 50).endsWith('…'),
      isTrue,
    );
  });
}
