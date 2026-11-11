import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/chat/domain/message.dart';
import 'package:chatpilot_app/features/conversations/domain/conversation.dart';

/// Demo seeds. Pass `languageCode` `en` / `zh` (default `en`).
///
/// Translator seed keeps assistant English replies as the contrast target;
/// only user lines follow the UI language.
List<Conversation> buildMockConversations({
  DateTime? now,
  String languageCode = 'en',
}) {
  final zh = languageCode.toLowerCase().startsWith('zh');
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

  final translatorTitle = zh ? '翻译' : 'Translator';
  final engineerTitle = zh ? '代码评审' : 'Code review';
  final writerTitle = zh ? '写作' : 'Writer';
  final generalTitle = zh ? '闲聊' : 'General chat';

  return [
    Conversation(
      id: 'conv-translator',
      title: translatorTitle,
      model: AiModel.mock,
      personaId: 'translator',
      createdAt: base.subtract(const Duration(minutes: 30)),
      updatedAt: base.subtract(const Duration(minutes: 5)),
      messages: [
        msg(
          't1',
          MessageRole.user,
          zh
              ? '帮我翻译：今天天气真好。'
              : 'Please translate: The weather is really nice today.',
          const Duration(minutes: 8),
        ),
        msg(
          't2',
          MessageRole.assistant,
          'The weather is really nice today.',
          const Duration(minutes: 7),
        ),
        msg(
          't3',
          MessageRole.user,
          zh
              ? '再润色一下，更自然。'
              : 'Polish it a bit — make it more natural.',
          const Duration(minutes: 6),
        ),
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
      title: engineerTitle,
      model: AiModel.mock,
      personaId: 'engineer',
      createdAt: base.subtract(const Duration(hours: 3)),
      updatedAt: base.subtract(const Duration(hours: 2)),
      messages: [
        msg(
          'e1',
          MessageRole.user,
          zh
              ? '这段 Dart 有 null 风险吗？`user!.name`'
              : 'Does this Dart have a null risk? `user!.name`',
          const Duration(hours: 2, minutes: 10),
        ),
        msg(
          'e2',
          MessageRole.assistant,
          zh
              ? '有。优先用 `user?.name` 或先判空，避免运行时崩溃。'
              : 'Yes. Prefer `user?.name` or a null check to avoid a runtime crash.',
          const Duration(hours: 2),
        ),
        msg(
          'e3',
          MessageRole.user,
          zh ? '给个安全写法示例。' : 'Show a safer example.',
          const Duration(hours: 1, minutes: 55),
        ),
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
      title: writerTitle,
      model: AiModel.mock,
      personaId: 'writer',
      createdAt: base.subtract(const Duration(days: 1)),
      updatedAt: base.subtract(const Duration(hours: 20)),
      messages: [
        msg(
          'w1',
          MessageRole.user,
          zh
              ? '帮我润色这封邮件开头。'
              : 'Help me polish this email opening.',
          const Duration(hours: 21),
        ),
        msg(
          'w2',
          MessageRole.assistant,
          'Hi Alex — quick note to follow up on yesterday’s demo.',
          const Duration(hours: 20, minutes: 50),
        ),
        msg(
          'w3',
          MessageRole.user,
          zh ? '再正式一点。' : 'Make it a bit more formal.',
          const Duration(hours: 20, minutes: 30),
        ),
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
      title: generalTitle,
      model: AiModel.mock,
      personaId: 'general',
      createdAt: base.subtract(const Duration(days: 3)),
      updatedAt: base.subtract(const Duration(days: 2)),
      messages: [
        msg(
          'g1',
          MessageRole.user,
          zh ? 'ChatPilot 能做什么？' : 'What can ChatPilot do?',
          const Duration(days: 2, hours: 2),
        ),
        msg(
          'g2',
          MessageRole.assistant,
          zh
              ? '可以聊天、切换人格，登录后还可同步历史。演示种子默认走 Mock。'
              : 'Chat, switch personas, and sync history when signed in. Demo seeds start in Mock mode.',
          const Duration(days: 2, hours: 1),
        ),
        msg(
          'g3',
          MessageRole.user,
          zh ? '不错，继续。' : 'Nice — keep going.',
          const Duration(days: 2),
        ),
      ],
    ),
  ];
}
