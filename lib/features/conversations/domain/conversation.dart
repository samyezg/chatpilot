import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/chat/domain/message.dart';

class Conversation {
  const Conversation({
    required this.id,
    required this.title,
    required this.model,
    required this.personaId,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final AiModel model;
  final String personaId;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get preview {
    if (messages.isEmpty) return 'New conversation';
    return messages.last.content;
  }

  Conversation copyWith({
    String? title,
    AiModel? model,
    String? personaId,
    List<Message>? messages,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id,
      title: title ?? this.title,
      model: model ?? this.model,
      personaId: personaId ?? this.personaId,
      messages: messages ?? this.messages,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
