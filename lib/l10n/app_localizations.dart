import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ChatPilot'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newChat;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUp;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @languageSectionHint.
  ///
  /// In en, this message translates to:
  /// **'Follow the device language, or lock English / Chinese. Unsupported system languages fall back to English.'**
  String get languageSectionHint;

  /// No description provided for @localOnlyBanner.
  ///
  /// In en, this message translates to:
  /// **'Local only — sign in to sync'**
  String get localOnlyBanner;

  /// No description provided for @noConversationsTitle.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversationsTitle;

  /// No description provided for @noConversationsBody.
  ///
  /// In en, this message translates to:
  /// **'Tap New to pick a persona and start chatting in Mock mode.'**
  String get noConversationsBody;

  /// No description provided for @renameConversation.
  ///
  /// In en, this message translates to:
  /// **'Rename conversation'**
  String get renameConversation;

  /// No description provided for @conversationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Conversation not found'**
  String get conversationNotFound;

  /// No description provided for @backToList.
  ///
  /// In en, this message translates to:
  /// **'Back to list'**
  String get backToList;

  /// No description provided for @listeningWithEngine.
  ///
  /// In en, this message translates to:
  /// **'Listening · {engine}'**
  String listeningWithEngine(String engine);

  /// No description provided for @voiceFallback.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voiceFallback;

  /// No description provided for @addApiKeyFirst.
  ///
  /// In en, this message translates to:
  /// **'Add a {provider} API key in Settings first.'**
  String addApiKeyFirst(String provider);

  /// No description provided for @generationStopped.
  ///
  /// In en, this message translates to:
  /// **'_(generation stopped)_'**
  String get generationStopped;

  /// No description provided for @generationStoppedSuffix.
  ///
  /// In en, this message translates to:
  /// **'\n\n_(stopped)_'**
  String get generationStoppedSuffix;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorPrefix(String message);

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {error}'**
  String unexpectedError(String error);

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Message…'**
  String get messageHint;

  /// No description provided for @listeningHint.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get listeningHint;

  /// No description provided for @voiceDictation.
  ///
  /// In en, this message translates to:
  /// **'Voice dictation'**
  String get voiceDictation;

  /// No description provided for @choosePersona.
  ///
  /// In en, this message translates to:
  /// **'Choose a persona'**
  String get choosePersona;

  /// No description provided for @startChat.
  ///
  /// In en, this message translates to:
  /// **'Start chat'**
  String get startChat;

  /// No description provided for @syncChatPilot.
  ///
  /// In en, this message translates to:
  /// **'Sync ChatPilot'**
  String get syncChatPilot;

  /// No description provided for @signInBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync conversations with Supabase. Without an account, chats stay on this device only.'**
  String get signInBody;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get signingIn;

  /// No description provided for @joinChatPilot.
  ///
  /// In en, this message translates to:
  /// **'Join ChatPilot'**
  String get joinChatPilot;

  /// No description provided for @signUpBody.
  ///
  /// In en, this message translates to:
  /// **'Email + password. With Supabase configured, this creates a real Auth user for cloud sync.'**
  String get signUpBody;

  /// No description provided for @passwordHelper.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordHelper;

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get creatingAccount;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email.'**
  String get enterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get enterValidEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get enterPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters.'**
  String get passwordTooShort;

  /// No description provided for @accountAndSync.
  ///
  /// In en, this message translates to:
  /// **'Account & sync'**
  String get accountAndSync;

  /// No description provided for @supabaseConfigured.
  ///
  /// In en, this message translates to:
  /// **'Supabase is configured. Sign in to sync conversations across devices.'**
  String get supabaseConfigured;

  /// No description provided for @supabaseNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Supabase not configured (local Fake Auth). Pass --dart-define-from-file=.vscode/supabase.local.json to enable cloud sync.'**
  String get supabaseNotConfigured;

  /// No description provided for @cloudSyncOn.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync on'**
  String get cloudSyncOn;

  /// No description provided for @localFakeSession.
  ///
  /// In en, this message translates to:
  /// **'Local fake session'**
  String get localFakeSession;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @syncFinished.
  ///
  /// In en, this message translates to:
  /// **'Sync finished'**
  String get syncFinished;

  /// No description provided for @apiKeys.
  ///
  /// In en, this message translates to:
  /// **'API keys'**
  String get apiKeys;

  /// No description provided for @apiKeysHint.
  ///
  /// In en, this message translates to:
  /// **'Keys stay in local SharedPreferences only — never bundled or committed. Each live model needs its own provider key.'**
  String get apiKeysHint;

  /// No description provided for @apiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'{provider} API key'**
  String apiKeyLabel(String provider);

  /// No description provided for @saveKey.
  ///
  /// In en, this message translates to:
  /// **'Save key'**
  String get saveKey;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @statusKeyPresent.
  ///
  /// In en, this message translates to:
  /// **'Status: key present'**
  String get statusKeyPresent;

  /// No description provided for @statusNoKey.
  ///
  /// In en, this message translates to:
  /// **'Status: no key'**
  String get statusNoKey;

  /// No description provided for @apiKeySaved.
  ///
  /// In en, this message translates to:
  /// **'{provider} API key saved on this device'**
  String apiKeySaved(String provider);

  /// No description provided for @apiKeyCleared.
  ///
  /// In en, this message translates to:
  /// **'{provider} API key cleared'**
  String apiKeyCleared(String provider);

  /// No description provided for @voiceDictationSection.
  ///
  /// In en, this message translates to:
  /// **'Voice dictation'**
  String get voiceDictationSection;

  /// No description provided for @voiceDictationHint.
  ///
  /// In en, this message translates to:
  /// **'Real dictation by default (Device STT). Auto may use Whisper next. Mock (demo) is explicit only — never a silent fallback.'**
  String get voiceDictationHint;

  /// No description provided for @voiceEngine.
  ///
  /// In en, this message translates to:
  /// **'Voice engine'**
  String get voiceEngine;

  /// No description provided for @voiceModeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get voiceModeAuto;

  /// No description provided for @voiceModeDevice.
  ///
  /// In en, this message translates to:
  /// **'Device STT'**
  String get voiceModeDevice;

  /// No description provided for @voiceModeWhisper.
  ///
  /// In en, this message translates to:
  /// **'OpenAI Whisper'**
  String get voiceModeWhisper;

  /// No description provided for @voiceModeMock.
  ///
  /// In en, this message translates to:
  /// **'Mock (demo)'**
  String get voiceModeMock;

  /// No description provided for @voiceModeAutoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Device streaming, then Whisper — never silent Mock fallback'**
  String get voiceModeAutoSubtitle;

  /// No description provided for @voiceModeDeviceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Live partials via platform speech recognition'**
  String get voiceModeDeviceSubtitle;

  /// No description provided for @voiceModeWhisperSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record → transcribe (listening UI, final on stop)'**
  String get voiceModeWhisperSubtitle;

  /// No description provided for @voiceModeMockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Demo phrase only — ignores microphone (explicit opt-in)'**
  String get voiceModeMockSubtitle;

  /// No description provided for @localData.
  ///
  /// In en, this message translates to:
  /// **'Local data'**
  String get localData;

  /// No description provided for @localDataHint.
  ///
  /// In en, this message translates to:
  /// **'Conversations are saved on this device (SharedPreferences). Restart keeps your chats.'**
  String get localDataHint;

  /// No description provided for @resetDemo.
  ///
  /// In en, this message translates to:
  /// **'Reset to demo conversations'**
  String get resetDemo;

  /// No description provided for @resetDemoDone.
  ///
  /// In en, this message translates to:
  /// **'Reset to demo conversations'**
  String get resetDemoDone;

  /// No description provided for @modelsSection.
  ///
  /// In en, this message translates to:
  /// **'Models'**
  String get modelsSection;

  /// No description provided for @modelStatusLiveKeyPresent.
  ///
  /// In en, this message translates to:
  /// **'{provider} · live SSE · key present'**
  String modelStatusLiveKeyPresent(String provider);

  /// No description provided for @modelStatusLiveAddKey.
  ///
  /// In en, this message translates to:
  /// **'{provider} · live SSE · add key to use'**
  String modelStatusLiveAddKey(String provider);

  /// No description provided for @modelStatusOfflineMock.
  ///
  /// In en, this message translates to:
  /// **'{provider} · offline mock stream'**
  String modelStatusOfflineMock(String provider);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// No description provided for @personaGeneralName.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get personaGeneralName;

  /// No description provided for @personaGeneralSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everyday Q&A'**
  String get personaGeneralSubtitle;

  /// No description provided for @personaTranslatorName.
  ///
  /// In en, this message translates to:
  /// **'Translator'**
  String get personaTranslatorName;

  /// No description provided for @personaTranslatorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Chinese ↔ English'**
  String get personaTranslatorSubtitle;

  /// No description provided for @personaWriterName.
  ///
  /// In en, this message translates to:
  /// **'Writer'**
  String get personaWriterName;

  /// No description provided for @personaWriterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Polish / expand / shorten'**
  String get personaWriterSubtitle;

  /// No description provided for @personaEngineerName.
  ///
  /// In en, this message translates to:
  /// **'Engineer'**
  String get personaEngineerName;

  /// No description provided for @personaEngineerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explain / review / debug'**
  String get personaEngineerSubtitle;

  /// No description provided for @personaTutorName.
  ///
  /// In en, this message translates to:
  /// **'Tutor'**
  String get personaTutorName;

  /// No description provided for @personaTutorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz / teach / summarize'**
  String get personaTutorSubtitle;

  /// No description provided for @seedTranslatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Translator'**
  String get seedTranslatorTitle;

  /// No description provided for @seedEngineerTitle.
  ///
  /// In en, this message translates to:
  /// **'Code review'**
  String get seedEngineerTitle;

  /// No description provided for @seedWriterTitle.
  ///
  /// In en, this message translates to:
  /// **'Writer'**
  String get seedWriterTitle;

  /// No description provided for @seedGeneralTitle.
  ///
  /// In en, this message translates to:
  /// **'General chat'**
  String get seedGeneralTitle;

  /// No description provided for @seedTranslatorUser1.
  ///
  /// In en, this message translates to:
  /// **'Please translate: The weather is really nice today.'**
  String get seedTranslatorUser1;

  /// No description provided for @seedTranslatorUser2.
  ///
  /// In en, this message translates to:
  /// **'Polish it a bit — make it more natural.'**
  String get seedTranslatorUser2;

  /// No description provided for @seedEngineerUser1.
  ///
  /// In en, this message translates to:
  /// **'Does this Dart have a null risk? `user!.name`'**
  String get seedEngineerUser1;

  /// No description provided for @seedEngineerAssistant1.
  ///
  /// In en, this message translates to:
  /// **'Yes. Prefer `user?.name` or a null check to avoid a runtime crash.'**
  String get seedEngineerAssistant1;

  /// No description provided for @seedEngineerUser2.
  ///
  /// In en, this message translates to:
  /// **'Show a safer example.'**
  String get seedEngineerUser2;

  /// No description provided for @seedEngineerAssistant2.
  ///
  /// In en, this message translates to:
  /// **'```dart\nfinal name = user?.name ?? \"Guest\";\n```'**
  String get seedEngineerAssistant2;

  /// No description provided for @seedWriterUser1.
  ///
  /// In en, this message translates to:
  /// **'Help me polish this email opening.'**
  String get seedWriterUser1;

  /// No description provided for @seedWriterAssistant1.
  ///
  /// In en, this message translates to:
  /// **'Hi Alex — quick note to follow up on yesterday’s demo.'**
  String get seedWriterAssistant1;

  /// No description provided for @seedWriterUser2.
  ///
  /// In en, this message translates to:
  /// **'Make it a bit more formal.'**
  String get seedWriterUser2;

  /// No description provided for @seedWriterAssistant2.
  ///
  /// In en, this message translates to:
  /// **'Dear Alex, I am writing to follow up on our demonstration yesterday.'**
  String get seedWriterAssistant2;

  /// No description provided for @seedGeneralUser1.
  ///
  /// In en, this message translates to:
  /// **'What can ChatPilot do?'**
  String get seedGeneralUser1;

  /// No description provided for @seedGeneralAssistant1.
  ///
  /// In en, this message translates to:
  /// **'Chat, switch personas, and sync history when signed in. Demo seeds start in Mock mode.'**
  String get seedGeneralAssistant1;

  /// No description provided for @seedGeneralUser2.
  ///
  /// In en, this message translates to:
  /// **'Nice — keep going.'**
  String get seedGeneralUser2;

  /// No description provided for @mockSttPhrase.
  ///
  /// In en, this message translates to:
  /// **'Hello, this is the ChatPilot streaming dictation demo.'**
  String get mockSttPhrase;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
