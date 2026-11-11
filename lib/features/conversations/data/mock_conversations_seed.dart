import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/chat/domain/message.dart';
import 'package:chatpilot_app/features/conversations/domain/conversation.dart';

List<Conversation> buildMockConversations({DateTime? now}) {
  final base = now ?? DateTime.utc(2026, 11, 10, 12);

  Message msg(
    String id,
    MessageRole role,
    String content,
    Duration ago,
  ) {
    return Message(
      id: id,
      role: role,
      content: content,
      createdAt: base.subtract(ago),
    );
  }

  return [
    Conversation(
      id: 'conv-translator',
      title: 'Translator',
      model: AiModel.mock,
      personaId: 'translator',
      createdAt: base.subtract(const Duration(minutes: 30)),
      updatedAt: base.subtract(const Duration(minutes: 5)),
      messages: [
        msg('t1', MessageRole.user, '帮我翻译：今天天气真好。', const Duration(minutes: 8)),
        msg(
          't2',
          MessageRole.assistant,
          'The weather is really nice today.',
          const Duration(minutes: 7),
        ),
        msg('t3', MessageRole.user, '再润色一下，更自然。', const Duration(minutes: 6)),
        msg(
          't4',
          MessageRole.assistant,
          "It's such a lovely day outside.",
          const Duration(minutes: 5),
        ),
      ],
    ),
    Conversation(
      id: 'conv-engineer',
      title: 'Code review',
      model: AiModel.mock,
      personaId: 'engineer',
      createdAt: base.subtract(const Duration(hours: 3)),
      updatedAt: base.subtract(const Duration(hours: 2)),
      messages: [
        msg(
          'e1',
          MessageRole.user,
          '这段 Dart 有 null 风险吗？`user!.name`',
          const Duration(hours: 2, minutes: 10),
        ),
        msg(
          'e2',
          MessageRole.assistant,
          '有。优先用 `user?.name` 或先判空，避免运行时崩溃。',
          const Duration(hours: 2),
        ),
        msg('e3', MessageRole.user, '给个安全写法示例。', const Duration(hours: 1, minutes: 55)),
        msg(
          'e4',
          MessageRole.assistant,
          '```dart\nfinal name = user?.name ?? "Guest";\n```',
          const Duration(hours: 1, minutes: 50),
        ),
      ],
    ),
    Conversation(
      id: 'conv-writer',
      title: 'Writer',
      model: AiModel.mock,
      personaId: 'writer',
      createdAt: base.subtract(const Duration(days: 1)),
      updatedAt: base.subtract(const Duration(hours: 20)),
      messages: [
        msg(
          'w1',
          MessageRole.user,
          '帮我润色这封邮件开头。',
          const Duration(hours: 21),
        ),
        msg(
          'w2',
          MessageRole.assistant,
          'Hi Alex — quick note to follow up on yesterday’s demo.',
          const Duration(hours: 20, minutes: 50),
        ),
        msg('w3', MessageRole.user, '再正式一点。', const Duration(hours: 20, minutes: 30)),
        msg(
          'w4',
          MessageRole.assistant,
          'Dear Alex, I am writing to follow up on our demonstration yesterday.',
          const Duration(hours: 20),
        ),
      ],
    ),
    Conversation(
      id: 'conv-general',
      title: 'General chat',
      model: AiModel.mock,
      personaId: 'general',
      createdAt: base.subtract(const Duration(days: 3)),
      updatedAt: base.subtract(const Duration(days: 2)),
      messages: [
        msg('g1', MessageRole.user, 'What can ChatPilot do?', const Duration(days: 2, hours: 2)),
        msg(
          'g2',
          MessageRole.assistant,
          'Chat, switch personas, and (later) sync history. Phase 1 is Mock-first.',
          const Duration(days: 2, hours: 1),
        ),
        msg('g3', MessageRole.user, 'Nice — keep going.', const Duration(days: 2)),
      ],
    ),
  ];
}
