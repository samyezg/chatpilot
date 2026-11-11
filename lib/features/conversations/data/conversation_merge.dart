import 'package:chatpilot_app/features/conversations/domain/conversation.dart';

/// Newer [Conversation.updatedAt] wins per id. Remote-only ids are appended.
List<Conversation> mergeConversationsByUpdatedAt({
  required List<Conversation> local,
  required List<Conversation> remote,
}) {
  final map = <String, Conversation>{
    for (final item in local) item.id: item,
  };

  for (final remoteItem in remote) {
    final existing = map[remoteItem.id];
    if (existing == null ||
        remoteItem.updatedAt.isAfter(existing.updatedAt) ||
        remoteItem.updatedAt.isAtSameMomentAs(existing.updatedAt)) {
      map[remoteItem.id] = remoteItem;
    }
  }

  final merged = map.values.toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return List.unmodifiable(merged);
}
