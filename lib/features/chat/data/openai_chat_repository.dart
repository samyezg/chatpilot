import 'package:chatpilot_app/features/chat/data/openai_compatible_chat_repository.dart';

/// OpenAI Chat Completions SSE.
class OpenAiChatRepository extends OpenAiCompatibleChatRepository {
  OpenAiChatRepository({
    required super.readApiKey,
    super.client,
    super.baseUrl = 'https://api.openai.com/v1',
  }) : super(providerName: 'OpenAI');
}
