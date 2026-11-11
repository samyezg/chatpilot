import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/chat/domain/message.dart';
import 'package:chatpilot_app/features/conversations/data/conversation_merge.dart';
import 'package:chatpilot_app/features/conversations/data/local_conversations_repository.dart';
import 'package:chatpilot_app/features/conversations/data/supabase_conversations_sync.dart';
import 'package:chatpilot_app/features/conversations/domain/conversation.dart';
import 'package:chatpilot_app/features/conversations/domain/conversations_repository.dart';

/// Local-first repository that best-effort pushes/pulls when signed in.
class SyncingConversationsRepository implements ConversationsRepository {
  SyncingConversationsRepository({
    required this.local,
    required this.sync,
  });

  final LocalConversationsRepository local;
  final SupabaseConversationsSync? sync;

  Future<void> pullAndMerge() async {
    final cloud = sync;
    if (cloud == null || !cloud.isSignedIn) return;
    try {
      final remote = await cloud.pullAll();
      final merged = mergeConversationsByUpdatedAt(
        local: local.list(),
        remote: remote,
      );
      await local.clearAndReseed(merged);
      for (final conversation in merged) {
        await cloud.pushConversation(conversation);
      }
    } catch (_) {
      // Keep local on network/RLS failures.
    }
  }

  Future<void> _push(Conversation? conversation) async {
    final cloud = sync;
    if (cloud == null || !cloud.isSignedIn || conversation == null) return;
    try {
      await cloud.pushConversation(conversation);
    } catch (_) {}
  }

  @override
  List<Conversation> list() => local.list();

  @override
  Conversation? getById(String id) => local.getById(id);

  @override
  Conversation create({
    required String personaId,
    required String title,
    AiModel model = AiModel.mock,
  }) {
    final created = local.create(
      personaId: personaId,
      title: title,
      model: model,
    );
    // ignore: discarded_futures
    _push(created);
    return created;
  }

  @override
  void upsert(Conversation conversation) {
    local.upsert(conversation);
    // ignore: discarded_futures
    _push(conversation);
  }

  @override
  void delete(String id) {
    local.delete(id);
    final cloud = sync;
    if (cloud != null && cloud.isSignedIn) {
      // ignore: discarded_futures
      cloud.deleteConversation(id);
    }
  }

  @override
  void rename(String id, String title) {
    local.rename(id, title);
    // ignore: discarded_futures
    _push(local.getById(id));
  }

  @override
  void setModel(String id, AiModel model) {
    local.setModel(id, model);
    // ignore: discarded_futures
    _push(local.getById(id));
  }

  @override
  void appendMessage(String conversationId, Message message) {
    local.appendMessage(conversationId, message);
    // ignore: discarded_futures
    _push(local.getById(conversationId));
  }

  @override
  void replaceMessage(String conversationId, Message message) {
    local.replaceMessage(conversationId, message);
    // ignore: discarded_futures
    _push(local.getById(conversationId));
  }

  Future<void> clearAndReseed([List<Conversation>? seed]) {
    return local.clearAndReseed(seed);
  }
}
