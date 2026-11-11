import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/chat/domain/chat_repository.dart';
import 'package:chatpilot_app/features/chat/domain/message.dart';
import 'package:chatpilot_app/features/persona/domain/persona.dart';

class MockChatRepository implements ChatRepository {
  MockChatRepository({
    this.thinkDelay = const Duration(seconds: 1),
    this.charDelay = const Duration(milliseconds: 16),
  });

  final Duration thinkDelay;
  final Duration charDelay;

  @override
  Stream<String> sendMessage({
    required AiModel model,
    required String message,
    required String personaId,
    List<Message> history = const [],
  }) async* {
    await Future<void>.delayed(thinkDelay);
    final reply = _craftReply(
      model: model,
      message: message,
      personaId: personaId,
    );
    if (reply.isEmpty) {
      yield '';
      return;
    }
    for (var i = 1; i <= reply.length; i++) {
      yield reply.substring(0, i);
      if (i < reply.length) {
        await Future<void>.delayed(charDelay);
      }
    }
  }

  String _craftReply({
    required AiModel model,
    required String message,
    required String personaId,
  }) {
    final name = Persona.byId(personaId)?.name ?? 'Assistant';
    final trimmed = message.trim();
    final preview =
        trimmed.length > 80 ? '${trimmed.substring(0, 80)}…' : trimmed;

    return switch (personaId) {
      'translator' =>
        '[$name · ${model.label}] Suggested translation:\n"$preview"\n\n'
            'Natural English: This is a mock translation for offline demos.',
      'writer' =>
        '[$name · ${model.label}] Polished draft:\n\n'
            '$preview\n\n'
            'I kept your intent and tightened the wording (Mock).',
      'engineer' =>
        '[$name · ${model.label}] Review notes:\n'
            '1) Clarify inputs/outputs\n'
            '2) Handle null / empty edge cases\n'
            '3) Add a small test\n\n'
            'Re: "$preview"',
      'tutor' =>
        '[$name · ${model.label}] Let\'s break it down:\n'
            '• Restate the question\n'
            '• Key idea in one sentence\n'
            '• Mini check: can you explain it back?\n\n'
            'Your prompt: "$preview"',
      _ =>
        '[$name · ${model.label}] Got it. (Mock reply)\n\n'
            'You said: "$preview"\n\n'
            'Mock streams this text with a typewriter effect. '
            'Switch to DeepSeek / GPT-4o / Claude / Gemini with your own keys.',
    };
  }
}
