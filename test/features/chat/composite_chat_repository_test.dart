import 'package:chatpilot_app/features/chat/data/composite_chat_repository.dart';
import 'package:chatpilot_app/features/chat/data/mock_chat_repository.dart';
import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/chat/domain/chat_repository.dart';
import 'package:chatpilot_app/features/chat/domain/message.dart';
import 'package:flutter_test/flutter_test.dart';

class _LabelRepo implements ChatRepository {
  _LabelRepo(this.label);

  final String label;

  @override
  Stream<String> sendMessage({
    required AiModel model,
    required String message,
    required String personaId,
    List<Message> history = const [],
  }) async* {
    yield '$label:$message';
  }
}

void main() {
  test('routes every AiModel to its repository', () async {
    final repo = CompositeChatRepository(
      mock: MockChatRepository(
        thinkDelay: Duration.zero,
        charDelay: Duration.zero,
      ),
      deepSeek: _LabelRepo('deepseek'),
      openAi: _LabelRepo('openai'),
      claude: _LabelRepo('claude'),
      gemini: _LabelRepo('gemini'),
    );

    final mockChunks = await repo
        .sendMessage(
          model: AiModel.mock,
          message: 'hi',
          personaId: 'general',
        )
        .toList();
    expect(mockChunks.last, contains('Mock'));

    Future<void> expectRoute(AiModel model, String label) async {
      final chunks = await repo
          .sendMessage(
            model: model,
            message: 'ping',
            personaId: 'general',
          )
          .toList();
      expect(chunks, ['$label:ping']);
    }

    await expectRoute(AiModel.deepseek, 'deepseek');
    await expectRoute(AiModel.gpt4o, 'openai');
    await expectRoute(AiModel.claude35, 'claude');
    await expectRoute(AiModel.gemini15, 'gemini');
  });
}
