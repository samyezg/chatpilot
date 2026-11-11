/// Local API-key slots (user-owned, device-only).
enum ApiKeyProvider {
  deepseek(
    prefsKey: 'api_key_deepseek',
    label: 'DeepSeek',
    hint: 'sk-…',
  ),
  openai(
    prefsKey: 'api_key_openai',
    label: 'OpenAI',
    hint: 'sk-…',
  ),
  anthropic(
    prefsKey: 'api_key_anthropic',
    label: 'Anthropic (Claude)',
    hint: 'sk-ant-…',
  ),
  google(
    prefsKey: 'api_key_google',
    label: 'Google (Gemini)',
    hint: 'AIza…',
  );

  const ApiKeyProvider({
    required this.prefsKey,
    required this.label,
    required this.hint,
  });

  final String prefsKey;
  final String label;
  final String hint;
}
