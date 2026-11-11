/// How ChatPilot picks a speech-to-text backend.
enum VoiceMode {
  /// Platform speech recognition with live partials (default — real dictation).
  device,
  /// Device STT → OpenAI Whisper only (never silent Mock).
  auto,
  /// Record then OpenAI `/audio/transcriptions` (needs OpenAI key).
  whisper,
  /// Offline demo stream — explicit opt-in only (ignores microphone).
  mock;

  String get label => switch (this) {
        VoiceMode.auto => 'Auto',
        VoiceMode.device => 'Device STT',
        VoiceMode.whisper => 'OpenAI Whisper',
        VoiceMode.mock => 'Mock (demo)',
      };

  String get subtitle => switch (this) {
        VoiceMode.auto =>
          'Device streaming, then Whisper — never silent Mock fallback',
        VoiceMode.device => 'Live partials via platform speech recognition',
        VoiceMode.whisper => 'Record → transcribe (listening UI, final on stop)',
        VoiceMode.mock =>
          'Demo phrase only — ignores microphone (explicit opt-in)',
      };
}
