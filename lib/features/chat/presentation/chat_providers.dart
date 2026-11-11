import 'package:chatpilot_app/features/chat/data/claude_chat_repository.dart';
import 'package:chatpilot_app/features/chat/data/composite_chat_repository.dart';
import 'package:chatpilot_app/features/chat/data/deepseek_chat_repository.dart';
import 'package:chatpilot_app/features/chat/data/gemini_chat_repository.dart';
import 'package:chatpilot_app/features/chat/data/mock_chat_repository.dart';
import 'package:chatpilot_app/features/chat/data/openai_chat_repository.dart';
import 'package:chatpilot_app/features/chat/domain/chat_repository.dart';
import 'package:chatpilot_app/features/settings/data/api_key_provider.dart';
import 'package:chatpilot_app/features/settings/presentation/settings_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final settings = ref.watch(settingsProvider);
  return CompositeChatRepository(
    mock: MockChatRepository(),
    deepSeek: DeepSeekChatRepository(
      readApiKey: () => settings.keyFor(ApiKeyProvider.deepseek),
    ),
    openAi: OpenAiChatRepository(
      readApiKey: () => settings.keyFor(ApiKeyProvider.openai),
    ),
    claude: ClaudeChatRepository(
      readApiKey: () => settings.keyFor(ApiKeyProvider.anthropic),
    ),
    gemini: GeminiChatRepository(
      readApiKey: () => settings.keyFor(ApiKeyProvider.google),
    ),
  );
});
