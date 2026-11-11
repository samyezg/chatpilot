import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/chat/domain/message.dart';
import 'package:chatpilot_app/features/conversations/data/mock_conversations_seed.dart';
import 'package:chatpilot_app/features/conversations/domain/conversation.dart';
import 'package:chatpilot_app/features/conversations/domain/conversations_repository.dart';

class InMemoryConversationsRepository implements ConversationsRepository {
  InMemoryConversationsRepository({List<Conversation>? seed})
      : _items = [...(seed ?? buildMockConversations())];

  final List<Conversation> _items;
  int _seq = 0;

  @override
  List<Conversation> list() {
    final copy = [..._items]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List.unmodifiable(copy);
  }

  @override
  Conversation? getById(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Conversation create({
    required String personaId,
    required String title,
    AiModel model = AiModel.mock,
  }) {
    _seq += 1;
    final now = DateTime.now().toUtc();
    final conversation = Conversation(
      id: 'conv-local-$_seq-${now.millisecondsSinceEpoch}',
      title: title,
      model: model,
      personaId: personaId,
      messages: const [],
      createdAt: now,
      updatedAt: now,
    );
    _items.insert(0, conversation);
    return conversation;
  }

  @override
  void upsert(Conversation conversation) {
    final index = _items.indexWhere((c) => c.id == conversation.id);
    if (index >= 0) {
      _items[index] = conversation;
    } else {
      _items.insert(0, conversation);
    }
  }

  @override
  void delete(String id) {
    _items.removeWhere((c) => c.id == id);
  }

  @override
  void rename(String id, String title) {
    final current = getById(id);
    if (current == null) return;
    upsert(
      current.copyWith(
        title: title.trim().isEmpty ? current.title : title.trim(),
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  @override
  void setModel(String id, AiModel model) {
    final current = getById(id);
    if (current == null) return;
    upsert(current.copyWith(model: model, updatedAt: DateTime.now().toUtc()));
  }

  @override
  void appendMessage(String conversationId, Message message) {
    final current = getById(conversationId);
    if (current == null) return;
    upsert(
      current.copyWith(
        messages: [...current.messages, message],
        updatedAt: message.createdAt,
      ),
    );
  }

  @override
  void replaceMessage(String conversationId, Message message) {
    final current = getById(conversationId);
    if (current == null) return;
    final next = [
      for (final item in current.messages)
        if (item.id == message.id) message else item,
    ];
    upsert(
      current.copyWith(
        messages: next,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }
}
