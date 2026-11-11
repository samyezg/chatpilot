import 'package:chatpilot_app/features/chat/data/openai_compatible_chat_repository.dart';

/// DeepSeek Chat — OpenAI-compatible SSE at api.deepseek.com.
class DeepSeekChatRepository extends OpenAiCompatibleChatRepository {
  DeepSeekChatRepository({
    required super.readApiKey,
    super.client,
    super.baseUrl = 'https://api.deepseek.com',
  }) : super(providerName: 'DeepSeek');
}
