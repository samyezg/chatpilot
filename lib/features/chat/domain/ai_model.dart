import 'package:chatpilot_app/features/settings/data/api_key_provider.dart';

/// Supported chat backends — all wired for live use when a key is present.
enum AiModel {
  mock(
    id: 'mock',
    apiModelId: 'mock',
    label: 'Mock',
    provider: 'Local',
    apiKeyProvider: null,
  ),
  deepseek(
    id: 'deepseek-chat',
    apiModelId: 'deepseek-chat',
    label: 'DeepSeek',
    provider: 'DeepSeek',
    apiKeyProvider: ApiKeyProvider.deepseek,
  ),
  gpt4o(
    id: 'gpt-4o',
    apiModelId: 'gpt-4o',
    label: 'GPT-4o',
    provider: 'OpenAI',
    apiKeyProvider: ApiKeyProvider.openai,
  ),
  claude35(
    id: 'claude-3.5-sonnet',
    apiModelId: 'claude-3-5-sonnet-latest',
    label: 'Claude 3.5',
    provider: 'Anthropic',
    apiKeyProvider: ApiKeyProvider.anthropic,
  ),
  gemini15(
    id: 'gemini-1.5-pro',
    apiModelId: 'gemini-1.5-pro',
    label: 'Gemini 1.5',
    provider: 'Google',
    apiKeyProvider: ApiKeyProvider.google,
  );

  const AiModel({
    required this.id,
    required this.apiModelId,
    required this.label,
    required this.provider,
    required this.apiKeyProvider,
  });

  /// Stable id persisted in conversations / sync.
  final String id;

  /// Vendor API model string (may differ from [id]).
  final String apiModelId;

  final String label;
  final String provider;
  final ApiKeyProvider? apiKeyProvider;

  bool get available => true;

  bool get needsApiKey => apiKeyProvider != null;

  String get menuLabel => '$label ($provider)';
}
