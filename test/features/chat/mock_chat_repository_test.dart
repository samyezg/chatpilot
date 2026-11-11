import 'package:chatpilot_app/features/chat/data/mock_chat_repository.dart';
import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mock chat streams a growing prefix then completes', () async {
    final repo = MockChatRepository(
      thinkDelay: Duration.zero,
      charDelay: Duration.zero,
    );

    final chunks = await repo
        .sendMessage(
          model: AiModel.mock,
          message: 'hello',
          personaId: 'general',
        )
        .toList();

    expect(chunks, isNotEmpty);
    expect(chunks.first.length, lessThanOrEqualTo(chunks.last.length));
    expect(chunks.last, contains('Mock'));
  });
}
