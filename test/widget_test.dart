import 'package:chatpilot_app/app/chatpilot_app.dart';
import 'package:chatpilot_app/app/config/app_environment.dart';
import 'package:chatpilot_app/app/config/app_environment_provider.dart';
import 'package:chatpilot_app/features/chat/data/mock_chat_repository.dart';
import 'package:chatpilot_app/features/chat/presentation/chat_providers.dart';
import 'package:chatpilot_app/features/conversations/data/local_conversations_repository.dart';
import 'package:chatpilot_app/features/conversations/presentation/conversations_notifier.dart';
import 'package:chatpilot_app/features/settings/presentation/settings_notifier.dart';
import 'package:chatpilot_app/features/voice/data/mock_streaming_stt_engine.dart';
import 'package:chatpilot_app/features/voice/presentation/voice_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final prefs = await SharedPreferences.getInstance();
    final conversations = LocalConversationsRepository.load(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvironmentProvider.overrideWithValue(AppEnvironment.mock),
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
          conversationsRepositoryProvider.overrideWithValue(conversations),
          chatRepositoryProvider.overrideWithValue(
            MockChatRepository(
              thinkDelay: Duration.zero,
              charDelay: Duration.zero,
            ),
          ),
          streamingSttEngineProvider.overrideWithValue(
            MockStreamingSttEngine(charDelay: Duration.zero),
          ),
        ],
        child: ChatPilotApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists mock conversations and opens a chat', (tester) async {
    await pumpApp(tester);

    expect(find.text('ChatPilot'), findsOneWidget);
    expect(find.text('Translator'), findsOneWidget);
    expect(find.text('Code review'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('conv-translator')));
    await tester.pumpAndSettle();

    expect(find.textContaining('The weather is really nice today.'), findsOneWidget);
    expect(find.byKey(const ValueKey('message-input')), findsOneWidget);
  });

  testWidgets('persona start creates chat and mock reply streams', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('new-chat')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('persona-tutor')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('start-chat-with-persona')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('message-input')), 'Explain gravity');
    await tester.tap(find.byKey(const ValueKey('message-send')));
    await tester.pumpAndSettle();

    // Message bubble + auto title from first user message.
    expect(find.text('Explain gravity'), findsWidgets);
    expect(find.textContaining('Mock'), findsWidgets);
  });

  testWidgets('settings can save deepseek key locally', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('open-settings')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('deepseek-api-key')),
      'sk-test-deepseek',
    );
    await tester.tap(find.byKey(const ValueKey('save-deepseek-key')));
    await tester.pumpAndSettle();

    expect(find.textContaining('DeepSeek · live SSE · key present'), findsOneWidget);
  });
}
