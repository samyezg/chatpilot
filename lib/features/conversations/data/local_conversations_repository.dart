import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/chat/domain/message.dart';
import 'package:chatpilot_app/features/conversations/data/conversation_codec.dart';
import 'package:chatpilot_app/features/conversations/data/in_memory_conversations_repository.dart';
import 'package:chatpilot_app/features/conversations/data/mock_conversations_seed.dart';
import 'package:chatpilot_app/features/conversations/domain/conversation.dart';
import 'package:chatpilot_app/features/conversations/domain/conversations_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists conversations as JSON in SharedPreferences.
class LocalConversationsRepository implements ConversationsRepository {
  LocalConversationsRepository._(this._prefs, this._memory);

  final SharedPreferences _prefs;
  final InMemoryConversationsRepository _memory;

  factory LocalConversationsRepository.load(
    SharedPreferences prefs, {
    List<Conversation>? seedIfEmpty,
  }) {
    final raw = prefs.getString(ConversationCodec.storageKey);
    late final List<Conversation> seed;
    if (raw == null || raw.trim().isEmpty) {
      seed = seedIfEmpty ?? buildMockConversations();
    } else {
      try {
        seed = ConversationCodec.decodeList(raw);
      } catch (_) {
        seed = seedIfEmpty ?? buildMockConversations();
      }
    }
    final repo = LocalConversationsRepository._(
      prefs,
      InMemoryConversationsRepository(seed: seed),
    );
    if (raw == null || raw.trim().isEmpty) {
      repo._persist();
    }
    return repo;
  }

  void _persist() {
    _prefs.setString(
      ConversationCodec.storageKey,
      ConversationCodec.encodeList(_memory.list()),
    );
  }

  @override
  List<Conversation> list() => _memory.list();

  @override
  Conversation? getById(String id) => _memory.getById(id);

  @override
  Conversation create({
    required String personaId,
    required String title,
    AiModel model = AiModel.mock,
  }) {
    final created = _memory.create(
      personaId: personaId,
      title: title,
      model: model,
    );
    _persist();
    return created;
  }

  @override
  void upsert(Conversation conversation) {
    _memory.upsert(conversation);
    _persist();
  }

  @override
  void delete(String id) {
    _memory.delete(id);
    _persist();
  }

  @override
  void rename(String id, String title) {
    _memory.rename(id, title);
    _persist();
  }

  @override
  void setModel(String id, AiModel model) {
    _memory.setModel(id, model);
    _persist();
  }

  @override
  void appendMessage(String conversationId, Message message) {
    final current = _memory.getById(conversationId);
    if (current == null) return;

    final titled = current.messages.isEmpty && message.role == MessageRole.user
        ? current.copyWith(
            title: ConversationCodec.titleFromFirstMessage(message.content),
          )
        : current;

    _memory.upsert(
      titled.copyWith(
        messages: [...titled.messages, message],
        updatedAt: message.createdAt,
      ),
    );
    _persist();
  }

  @override
  void replaceMessage(String conversationId, Message message) {
    _memory.replaceMessage(conversationId, message);
    _persist();
  }

  Future<void> clearAndReseed([List<Conversation>? seed]) async {
    final next = seed ?? buildMockConversations();
    for (final item in _memory.list()) {
      _memory.delete(item.id);
    }
    for (final item in next) {
      _memory.upsert(item);
    }
    _persist();
  }
}
