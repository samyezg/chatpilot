import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/chat/domain/message.dart';

/// Streams assistant text chunks (full prefix each time for simple UI binding).
abstract class ChatRepository {
  Stream<String> sendMessage({
    required AiModel model,
    required String message,
    required String personaId,
    List<Message> history = const [],
  });
}
