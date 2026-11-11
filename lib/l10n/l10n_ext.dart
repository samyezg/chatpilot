import 'package:chatpilot_app/features/voice/domain/voice_mode.dart';
import 'package:chatpilot_app/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

export 'package:chatpilot_app/l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension PersonaLocalizations on AppLocalizations {
  String personaName(String id) => switch (id) {
        'translator' => personaTranslatorName,
        'writer' => personaWriterName,
        'engineer' => personaEngineerName,
        'tutor' => personaTutorName,
        _ => personaGeneralName,
      };

  String personaSubtitle(String id) => switch (id) {
        'translator' => personaTranslatorSubtitle,
        'writer' => personaWriterSubtitle,
        'engineer' => personaEngineerSubtitle,
        'tutor' => personaTutorSubtitle,
        _ => personaGeneralSubtitle,
      };
}

extension VoiceModeLocalizations on AppLocalizations {
  String voiceModeLabel(VoiceMode mode) => switch (mode) {
        VoiceMode.auto => voiceModeAuto,
        VoiceMode.device => voiceModeDevice,
        VoiceMode.whisper => voiceModeWhisper,
        VoiceMode.mock => voiceModeMock,
      };

  String voiceModeSubtitle(VoiceMode mode) => switch (mode) {
        VoiceMode.auto => voiceModeAutoSubtitle,
        VoiceMode.device => voiceModeDeviceSubtitle,
        VoiceMode.whisper => voiceModeWhisperSubtitle,
        VoiceMode.mock => voiceModeMockSubtitle,
      };
}
