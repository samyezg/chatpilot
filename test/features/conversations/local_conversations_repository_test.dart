import 'package:chatpilot_app/features/chat/domain/message.dart';
import 'package:chatpilot_app/features/conversations/data/conversation_codec.dart';
import 'package:chatpilot_app/features/conversations/data/local_conversations_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists create/rename/delete across reload', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = LocalConversationsRepository.load(
      prefs,
      seedIfEmpty: const [],
    );

    final created = repo.create(personaId: 'tutor', title: 'Tutor');
    repo.appendMessage(
      created.id,
      Message(
        id: 'u1',
        role: MessageRole.user,
        content: 'Explain gravity simply',
        createdAt: DateTime.utc(2026, 11, 10),
      ),
    );

    final reloaded = LocalConversationsRepository.load(prefs);
    final again = reloaded.getById(created.id);
    expect(again, isNotNull);
    expect(again!.title, 'Explain gravity simply');
    expect(again.messages, hasLength(1));
    expect(prefs.getString(ConversationCodec.storageKey), isNotNull);

    reloaded.delete(created.id);
    final empty = LocalConversationsRepository.load(prefs);
    expect(empty.getById(created.id), isNull);
  });
}
