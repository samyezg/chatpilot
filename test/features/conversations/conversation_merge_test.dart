import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/conversations/data/conversation_merge.dart';
import 'package:chatpilot_app/features/conversations/domain/conversation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Conversation conv(
    String id,
    DateTime updatedAt, {
    String title = 't',
  }) {
    return Conversation(
      id: id,
      title: title,
      model: AiModel.mock,
      personaId: 'general',
      messages: const [],
      createdAt: updatedAt,
      updatedAt: updatedAt,
    );
  }

  test('newer updatedAt wins; remote-only ids kept', () {
    final local = [
      conv('a', DateTime.utc(2026, 1, 1), title: 'local-a'),
      conv('b', DateTime.utc(2026, 1, 2), title: 'local-b'),
    ];
    final remote = [
      conv('a', DateTime.utc(2026, 1, 3), title: 'remote-a'),
      conv('c', DateTime.utc(2026, 1, 4), title: 'remote-c'),
    ];

    final merged = mergeConversationsByUpdatedAt(local: local, remote: remote);
    expect(merged.map((c) => c.id).toList(), ['c', 'a', 'b']);
    expect(merged.firstWhere((c) => c.id == 'a').title, 'remote-a');
    expect(merged.firstWhere((c) => c.id == 'b').title, 'local-b');
  });
}
