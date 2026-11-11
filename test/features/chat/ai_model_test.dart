import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/settings/data/api_key_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all models are available; live ones need API keys', () {
    expect(AiModel.values.every((m) => m.available), isTrue);
    expect(AiModel.mock.needsApiKey, isFalse);
    expect(AiModel.deepseek.needsApiKey, isTrue);
    expect(AiModel.gpt4o.needsApiKey, isTrue);
    expect(AiModel.claude35.needsApiKey, isTrue);
    expect(AiModel.gemini15.needsApiKey, isTrue);
    expect(AiModel.gpt4o.apiKeyProvider, ApiKeyProvider.openai);
    expect(AiModel.claude35.apiModelId, 'claude-3-5-sonnet-latest');
  });
}
