import 'dart:convert';

import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/chat/domain/message.dart';
import 'package:chatpilot_app/features/conversations/domain/conversation.dart';

abstract final class ConversationCodec {
  static const storageKey = 'chatpilot_conversations_v1';

  static String encodeList(List<Conversation> conversations) {
    final payload = conversations.map(toJson).toList(growable: false);
    return jsonEncode(payload);
  }

  static List<Conversation> decodeList(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return [
      for (final item in decoded)
        if (item is Map<String, dynamic>) fromJson(item)
        else if (item is Map) fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  static Map<String, dynamic> toJson(Conversation conversation) {
    return {
      'id': conversation.id,
      'title': conversation.title,
      'model': conversation.model.id,
      'personaId': conversation.personaId,
      'createdAt': conversation.createdAt.toIso8601String(),
      'updatedAt': conversation.updatedAt.toIso8601String(),
      'messages': [
        for (final message in conversation.messages) messageToJson(message),
      ],
    };
  }

  static Conversation fromJson(Map<String, dynamic> json) {
    final messagesRaw = json['messages'];
    final messages = <Message>[];
    if (messagesRaw is List) {
      for (final item in messagesRaw) {
        if (item is Map<String, dynamic>) {
          messages.add(messageFromJson(item));
        } else if (item is Map) {
          messages.add(messageFromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Chat',
      model: _modelFromId(json['model'] as String?),
      personaId: json['personaId'] as String? ?? 'general',
      messages: List.unmodifiable(messages),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
    );
  }

  static Map<String, dynamic> messageToJson(Message message) {
    return {
      'id': message.id,
      'role': message.role.name,
      'content': message.content,
      'createdAt': message.createdAt.toIso8601String(),
    };
  }

  static Message messageFromJson(Map<String, dynamic> json) {
    final roleName = json['role'] as String? ?? 'user';
    return Message(
      id: json['id'] as String,
      role: MessageRole.values.firstWhere(
        (role) => role.name == roleName,
        orElse: () => MessageRole.user,
      ),
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
    );
  }

  static AiModel _modelFromId(String? id) {
    for (final model in AiModel.values) {
      if (model.id == id) return model;
    }
    return AiModel.mock;
  }

  static String titleFromFirstMessage(String content) {
    final trimmed = content.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmed.isEmpty) return 'New chat';
    if (trimmed.length <= 36) return trimmed;
    return '${trimmed.substring(0, 36)}…';
  }
}
