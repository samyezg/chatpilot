import 'package:chatpilot_app/features/chat/domain/message.dart';
import 'package:chatpilot_app/features/persona/domain/persona.dart';

String systemPromptFor(String personaId) {
  return Persona.byId(personaId)?.systemPrompt ??
      'You are ChatPilot, a helpful assistant.';
}

/// Prior turns only — the current user [message] is appended by each client.
List<Message> priorTurns(List<Message> history) {
  return [
    for (final item in history)
      if (item.content.trim().isNotEmpty) item,
  ];
}

List<Map<String, String>> openAiStyleMessages({
  required String personaId,
  required String message,
  required List<Message> history,
}) {
  return [
    {'role': 'system', 'content': systemPromptFor(personaId)},
    for (final item in priorTurns(history))
      {
        'role': item.role == MessageRole.user ? 'user' : 'assistant',
        'content': item.content,
      },
    {'role': 'user', 'content': message},
  ];
}
