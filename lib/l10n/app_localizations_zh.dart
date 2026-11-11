// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'ChatPilot';

  @override
  String get settings => '设置';

  @override
  String get newChat => '新建';

  @override
  String get signIn => '登录';

  @override
  String get signOut => '退出登录';

  @override
  String get signUp => '创建账户';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get clear => '清除';

  @override
  String get chat => '聊天';

  @override
  String get copied => '已复制';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get title => '标题';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get languageSectionHint => '跟随设备语言，或锁定为英文 / 中文。系统语言不在支持列表时回退英文。';

  @override
  String get localOnlyBanner => '仅本地 — 登录后可同步';

  @override
  String get noConversationsTitle => '还没有对话';

  @override
  String get noConversationsBody => '点「新建」选择人格，即可用 Mock 模式开始聊天。';

  @override
  String get renameConversation => '重命名对话';

  @override
  String get conversationNotFound => '找不到该对话';

  @override
  String get backToList => '返回列表';

  @override
  String listeningWithEngine(String engine) {
    return '听写中 · $engine';
  }

  @override
  String get voiceFallback => '语音';

  @override
  String addApiKeyFirst(String provider) {
    return '请先在设置中填写 $provider API Key。';
  }

  @override
  String get generationStopped => '_(已停止生成)_';

  @override
  String get generationStoppedSuffix => '\n\n_(已停止)_';

  @override
  String errorPrefix(String message) {
    return '错误：$message';
  }

  @override
  String unexpectedError(String error) {
    return '意外错误：$error';
  }

  @override
  String get messageHint => '输入消息…';

  @override
  String get listeningHint => '正在听写…';

  @override
  String get voiceDictation => '语音听写';

  @override
  String get choosePersona => '选择人格';

  @override
  String get startChat => '开始聊天';

  @override
  String get syncChatPilot => '同步 ChatPilot';

  @override
  String get signInBody => '登录后可将对话同步到 Supabase。未登录时对话仅保存在本机。';

  @override
  String get signingIn => '正在登录…';

  @override
  String get joinChatPilot => '加入 ChatPilot';

  @override
  String get signUpBody => '邮箱 + 密码。已配置 Supabase 时会创建真实 Auth 用户用于云同步。';

  @override
  String get passwordHelper => '至少 6 个字符';

  @override
  String get creatingAccount => '正在创建…';

  @override
  String get backToSignIn => '返回登录';

  @override
  String get enterEmail => '请输入邮箱。';

  @override
  String get enterValidEmail => '请输入有效邮箱。';

  @override
  String get enterPassword => '请输入密码。';

  @override
  String get passwordTooShort => '密码至少 6 个字符。';

  @override
  String get accountAndSync => '账户与同步';

  @override
  String get supabaseConfigured => '已配置 Supabase。登录后可在多设备同步对话。';

  @override
  String get supabaseNotConfigured =>
      '未配置 Supabase（本地 Fake Auth）。传入 --dart-define-from-file=.vscode/supabase.local.json 可启用云同步。';

  @override
  String get cloudSyncOn => '云同步已开启';

  @override
  String get localFakeSession => '本地模拟会话';

  @override
  String get syncNow => '立即同步';

  @override
  String get syncFinished => '同步完成';

  @override
  String get apiKeys => 'API 密钥';

  @override
  String get apiKeysHint =>
      '密钥仅保存在本机 SharedPreferences，不会打包或提交。每个在线模型需要对应厂商的 Key。';

  @override
  String apiKeyLabel(String provider) {
    return '$provider API 密钥';
  }

  @override
  String get saveKey => '保存密钥';

  @override
  String get saving => '保存中…';

  @override
  String get statusKeyPresent => '状态：已保存密钥';

  @override
  String get statusNoKey => '状态：未填写密钥';

  @override
  String apiKeySaved(String provider) {
    return '$provider API 密钥已保存在本机';
  }

  @override
  String apiKeyCleared(String provider) {
    return '$provider API 密钥已清除';
  }

  @override
  String get voiceDictationSection => '语音听写';

  @override
  String get voiceDictationHint =>
      '默认真实听写（设备 STT）。Auto 可再试 Whisper。Mock（演示）仅手动选择——不会静默兜底灌字。';

  @override
  String get voiceEngine => '听写引擎';

  @override
  String get voiceModeAuto => '自动';

  @override
  String get voiceModeDevice => '设备 STT';

  @override
  String get voiceModeWhisper => 'OpenAI Whisper';

  @override
  String get voiceModeMock => 'Mock（演示）';

  @override
  String get voiceModeAutoSubtitle => '设备流式，其次 Whisper——绝不静默落到 Mock';

  @override
  String get voiceModeDeviceSubtitle => '系统语音识别，实时 partial';

  @override
  String get voiceModeWhisperSubtitle => '录音 → 转写（停止后出最终结果）';

  @override
  String get voiceModeMockSubtitle => '仅演示固定句，忽略麦克风（需显式选择）';

  @override
  String get localData => '本地数据';

  @override
  String get localDataHint => '对话保存在本机 SharedPreferences。重启后仍会保留。';

  @override
  String get resetDemo => '恢复演示对话';

  @override
  String get resetDemoDone => '已恢复演示对话';

  @override
  String get modelsSection => '模型';

  @override
  String modelStatusLiveKeyPresent(String provider) {
    return '$provider · 在线 SSE · 已有密钥';
  }

  @override
  String modelStatusLiveAddKey(String provider) {
    return '$provider · 在线 SSE · 需填写密钥';
  }

  @override
  String modelStatusOfflineMock(String provider) {
    return '$provider · 离线 Mock 流';
  }

  @override
  String get justNow => '刚刚';

  @override
  String minutesAgo(int count) {
    return '$count 分钟前';
  }

  @override
  String hoursAgo(int count) {
    return '$count 小时前';
  }

  @override
  String get yesterday => '昨天';

  @override
  String daysAgo(int count) {
    return '$count 天前';
  }

  @override
  String get personaGeneralName => '通用助手';

  @override
  String get personaGeneralSubtitle => '日常问答';

  @override
  String get personaTranslatorName => '翻译';

  @override
  String get personaTranslatorSubtitle => '中英互译';

  @override
  String get personaWriterName => '写作';

  @override
  String get personaWriterSubtitle => '润色 / 扩写 / 精简';

  @override
  String get personaEngineerName => '工程师';

  @override
  String get personaEngineerSubtitle => '讲解 / 评审 / 排错';

  @override
  String get personaTutorName => '导师';

  @override
  String get personaTutorSubtitle => '测验 / 教学 / 总结';

  @override
  String get seedTranslatorTitle => '翻译';

  @override
  String get seedEngineerTitle => '代码评审';

  @override
  String get seedWriterTitle => '写作';

  @override
  String get seedGeneralTitle => '闲聊';

  @override
  String get seedTranslatorUser1 => '帮我翻译：今天天气真好。';

  @override
  String get seedTranslatorUser2 => '再润色一下，更自然。';

  @override
  String get seedEngineerUser1 => '这段 Dart 有 null 风险吗？`user!.name`';

  @override
  String get seedEngineerAssistant1 => '有。优先用 `user?.name` 或先判空，避免运行时崩溃。';

  @override
  String get seedEngineerUser2 => '给个安全写法示例。';

  @override
  String get seedEngineerAssistant2 =>
      '```dart\nfinal name = user?.name ?? \"Guest\";\n```';

  @override
  String get seedWriterUser1 => '帮我润色这封邮件开头。';

  @override
  String get seedWriterAssistant1 =>
      'Hi Alex — quick note to follow up on yesterday’s demo.';

  @override
  String get seedWriterUser2 => '再正式一点。';

  @override
  String get seedWriterAssistant2 =>
      'Dear Alex, I am writing to follow up on our demonstration yesterday.';

  @override
  String get seedGeneralUser1 => 'ChatPilot 能做什么？';

  @override
  String get seedGeneralAssistant1 => '可以聊天、切换人格，登录后还可同步历史。演示种子默认走 Mock。';

  @override
  String get seedGeneralUser2 => '不错，继续。';

  @override
  String get mockSttPhrase => '你好，这是 ChatPilot 流式听写演示。';
}
