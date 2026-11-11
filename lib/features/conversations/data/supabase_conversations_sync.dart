import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/chat/domain/message.dart';
import 'package:chatpilot_app/features/conversations/domain/conversation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConversationsSync {
  SupabaseConversationsSync(this._client);

  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  bool get isSignedIn => _userId != null;

  Future<List<Conversation>> pullAll() async {
    final userId = _userId;
    if (userId == null) return const [];

    final rows = await _client
        .from('conversations')
        .select('*, messages(*)')
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return [
      for (final row in rows as List<dynamic>)
        _mapConversation(Map<String, dynamic>.from(row as Map)),
    ];
  }

  Future<void> pushConversation(Conversation conversation) async {
    final userId = _userId;
    if (userId == null) return;

    await _client.from('conversations').upsert({
      'id': conversation.id,
      'user_id': userId,
      'title': conversation.title,
      'model': conversation.model.id,
      'persona': conversation.personaId,
      'created_at': conversation.createdAt.toIso8601String(),
      'updated_at': conversation.updatedAt.toIso8601String(),
    });

    // Replace messages for this conversation (simple, reliable for MVP).
    await _client
        .from('messages')
        .delete()
        .eq('conversation_id', conversation.id);

    if (conversation.messages.isEmpty) return;

    await _client.from('messages').insert([
      for (final message in conversation.messages)
        {
          'id': message.id,
          'conversation_id': conversation.id,
          'role': message.role.name,
          'content': message.content,
          'created_at': message.createdAt.toIso8601String(),
        },
    ]);
  }

  Future<void> deleteConversation(String id) async {
    if (_userId == null) return;
    await _client.from('conversations').delete().eq('id', id);
  }

  Conversation _mapConversation(Map<String, dynamic> row) {
    final messagesRaw = row['messages'];
    final messages = <Message>[];
    if (messagesRaw is List) {
      for (final item in messagesRaw) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final roleName = map['role'] as String? ?? 'user';
        messages.add(
          Message(
            id: map['id'] as String,
            role: MessageRole.values.firstWhere(
              (role) => role.name == roleName,
              orElse: () => MessageRole.user,
            ),
            content: map['content'] as String? ?? '',
            createdAt:
                DateTime.tryParse(map['created_at'] as String? ?? '') ??
                    DateTime.now().toUtc(),
          ),
        );
      }
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return Conversation(
      id: row['id'] as String,
      title: row['title'] as String? ?? 'Chat',
      model: _modelFromId(row['model'] as String?),
      personaId: row['persona'] as String? ?? 'general',
      messages: List.unmodifiable(messages),
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
      updatedAt: DateTime.tryParse(row['updated_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
    );
  }

  AiModel _modelFromId(String? id) {
    for (final model in AiModel.values) {
      if (model.id == id) return model;
    }
    return AiModel.mock;
  }
}
