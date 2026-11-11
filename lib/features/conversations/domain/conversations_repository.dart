import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/chat/domain/message.dart';
import 'package:chatpilot_app/features/conversations/domain/conversation.dart';

abstract class ConversationsRepository {
  List<Conversation> list();

  Conversation? getById(String id);

  Conversation create({
    required String personaId,
    required String title,
    AiModel model = AiModel.mock,
  });

  void upsert(Conversation conversation);

  void delete(String id);

  void rename(String id, String title);

  void setModel(String id, AiModel model);

  void appendMessage(String conversationId, Message message);

  void replaceMessage(String conversationId, Message message);
}
