// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ChatPilot';

  @override
  String get settings => 'Settings';

  @override
  String get newChat => 'New';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get signUp => 'Create account';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get clear => 'Clear';

  @override
  String get chat => 'Chat';

  @override
  String get copied => 'Copied';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get title => 'Title';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get languageSectionHint =>
      'Follow the device language, or lock English / Chinese. Unsupported system languages fall back to English.';

  @override
  String get localOnlyBanner => 'Local only — sign in to sync';

  @override
  String get noConversationsTitle => 'No conversations yet';

  @override
  String get noConversationsBody =>
      'Tap New to pick a persona and start chatting in Mock mode.';

  @override
  String get renameConversation => 'Rename conversation';

  @override
  String get conversationNotFound => 'Conversation not found';

  @override
  String get backToList => 'Back to list';

  @override
  String listeningWithEngine(String engine) {
    return 'Listening · $engine';
  }

  @override
  String get voiceFallback => 'Voice';

  @override
  String addApiKeyFirst(String provider) {
    return 'Add a $provider API key in Settings first.';
  }

  @override
  String get generationStopped => '_(generation stopped)_';

  @override
  String get generationStoppedSuffix => '\n\n_(stopped)_';

  @override
  String errorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String unexpectedError(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String get messageHint => 'Message…';

  @override
  String get listeningHint => 'Listening…';

  @override
  String get voiceDictation => 'Voice dictation';

  @override
  String get choosePersona => 'Choose a persona';

  @override
  String get startChat => 'Start chat';

  @override
  String get syncChatPilot => 'Sync ChatPilot';

  @override
  String get signInBody =>
      'Sign in to sync conversations with Supabase. Without an account, chats stay on this device only.';

  @override
  String get signingIn => 'Signing in…';

  @override
  String get joinChatPilot => 'Join ChatPilot';

  @override
  String get signUpBody =>
      'Email + password. With Supabase configured, this creates a real Auth user for cloud sync.';

  @override
  String get passwordHelper => 'At least 6 characters';

  @override
  String get creatingAccount => 'Creating…';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get enterEmail => 'Enter your email.';

  @override
  String get enterValidEmail => 'Enter a valid email.';

  @override
  String get enterPassword => 'Enter your password.';

  @override
  String get passwordTooShort => 'Use at least 6 characters.';

  @override
  String get accountAndSync => 'Account & sync';

  @override
  String get supabaseConfigured =>
      'Supabase is configured. Sign in to sync conversations across devices.';

  @override
  String get supabaseNotConfigured =>
      'Supabase not configured (local Fake Auth). Pass --dart-define-from-file=.vscode/supabase.local.json to enable cloud sync.';

  @override
  String get cloudSyncOn => 'Cloud sync on';

  @override
  String get localFakeSession => 'Local fake session';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncFinished => 'Sync finished';

  @override
  String get apiKeys => 'API keys';

  @override
  String get apiKeysHint =>
      'Keys stay in local SharedPreferences only — never bundled or committed. Each live model needs its own provider key.';

  @override
  String apiKeyLabel(String provider) {
    return '$provider API key';
  }

  @override
  String get saveKey => 'Save key';

  @override
  String get saving => 'Saving…';

  @override
  String get statusKeyPresent => 'Status: key present';

  @override
  String get statusNoKey => 'Status: no key';

  @override
  String apiKeySaved(String provider) {
    return '$provider API key saved on this device';
  }

  @override
  String apiKeyCleared(String provider) {
    return '$provider API key cleared';
  }

  @override
  String get voiceDictationSection => 'Voice dictation';

  @override
  String get voiceDictationHint =>
      'Real dictation by default (Device STT). Auto may use Whisper next. Mock (demo) is explicit only — never a silent fallback.';

  @override
  String get voiceEngine => 'Voice engine';

  @override
  String get voiceModeAuto => 'Auto';

  @override
  String get voiceModeDevice => 'Device STT';

  @override
  String get voiceModeWhisper => 'OpenAI Whisper';

  @override
  String get voiceModeMock => 'Mock (demo)';

  @override
  String get voiceModeAutoSubtitle =>
      'Device streaming, then Whisper — never silent Mock fallback';

  @override
  String get voiceModeDeviceSubtitle =>
      'Live partials via platform speech recognition';

  @override
  String get voiceModeWhisperSubtitle =>
      'Record → transcribe (listening UI, final on stop)';

  @override
  String get voiceModeMockSubtitle =>
      'Demo phrase only — ignores microphone (explicit opt-in)';

  @override
  String get localData => 'Local data';

  @override
  String get localDataHint =>
      'Conversations are saved on this device (SharedPreferences). Restart keeps your chats.';

  @override
  String get resetDemo => 'Reset to demo conversations';

  @override
  String get resetDemoDone => 'Reset to demo conversations';

  @override
  String get modelsSection => 'Models';

  @override
  String modelStatusLiveKeyPresent(String provider) {
    return '$provider · live SSE · key present';
  }

  @override
  String modelStatusLiveAddKey(String provider) {
    return '$provider · live SSE · add key to use';
  }

  @override
  String modelStatusOfflineMock(String provider) {
    return '$provider · offline mock stream';
  }

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get personaGeneralName => 'General';

  @override
  String get personaGeneralSubtitle => 'Everyday Q&A';

  @override
  String get personaTranslatorName => 'Translator';

  @override
  String get personaTranslatorSubtitle => 'Chinese ↔ English';

  @override
  String get personaWriterName => 'Writer';

  @override
  String get personaWriterSubtitle => 'Polish / expand / shorten';

  @override
  String get personaEngineerName => 'Engineer';

  @override
  String get personaEngineerSubtitle => 'Explain / review / debug';

  @override
  String get personaTutorName => 'Tutor';

  @override
  String get personaTutorSubtitle => 'Quiz / teach / summarize';

  @override
  String get seedTranslatorTitle => 'Translator';

  @override
  String get seedEngineerTitle => 'Code review';

  @override
  String get seedWriterTitle => 'Writer';

  @override
  String get seedGeneralTitle => 'General chat';

  @override
  String get seedTranslatorUser1 =>
      'Please translate: The weather is really nice today.';

  @override
  String get seedTranslatorUser2 => 'Polish it a bit — make it more natural.';

  @override
  String get seedEngineerUser1 =>
      'Does this Dart have a null risk? `user!.name`';

  @override
  String get seedEngineerAssistant1 =>
      'Yes. Prefer `user?.name` or a null check to avoid a runtime crash.';

  @override
  String get seedEngineerUser2 => 'Show a safer example.';

  @override
  String get seedEngineerAssistant2 =>
      '```dart\nfinal name = user?.name ?? \"Guest\";\n```';

  @override
  String get seedWriterUser1 => 'Help me polish this email opening.';

  @override
  String get seedWriterAssistant1 =>
      'Hi Alex — quick note to follow up on yesterday’s demo.';

  @override
  String get seedWriterUser2 => 'Make it a bit more formal.';

  @override
  String get seedWriterAssistant2 =>
      'Dear Alex, I am writing to follow up on our demonstration yesterday.';

  @override
  String get seedGeneralUser1 => 'What can ChatPilot do?';

  @override
  String get seedGeneralAssistant1 =>
      'Chat, switch personas, and sync history when signed in. Demo seeds start in Mock mode.';

  @override
  String get seedGeneralUser2 => 'Nice — keep going.';

  @override
  String get mockSttPhrase =>
      'Hello, this is the ChatPilot streaming dictation demo.';
}
