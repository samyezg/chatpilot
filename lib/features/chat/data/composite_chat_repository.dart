import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/chat/domain/chat_repository.dart';
import 'package:chatpilot_app/features/chat/domain/message.dart';

class CompositeChatRepository implements ChatRepository {
  const CompositeChatRepository({
    required this.mock,
    required this.deepSeek,
    required this.openAi,
    required this.claude,
    required this.gemini,
  });

  final ChatRepository mock;
  final ChatRepository deepSeek;
  final ChatRepository openAi;
  final ChatRepository claude;
  final ChatRepository gemini;

  @override
  Stream<String> sendMessage({
    required AiModel model,
    required String message,
    required String personaId,
    List<Message> history = const [],
  }) {
    final repo = switch (model) {
      AiModel.mock => mock,
      AiModel.deepseek => deepSeek,
      AiModel.gpt4o => openAi,
      AiModel.claude35 => claude,
      AiModel.gemini15 => gemini,
    };

    return repo.sendMessage(
      model: model,
      message: message,
      personaId: personaId,
      history: history,
    );
  }
}
