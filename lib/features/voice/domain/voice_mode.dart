/// How ChatPilot picks a speech-to-text backend.
enum VoiceMode {
  /// Device STT → OpenAI Whisper → Mock.
  auto,
  /// Platform speech recognition with live partials.
  device,
  /// Record then OpenAI `/audio/transcriptions` (needs OpenAI key).
  whisper,
  /// Offline demo stream (no mic / no key).
  mock;

  String get label => switch (this) {
        VoiceMode.auto => 'Auto',
        VoiceMode.device => 'Device STT',
        VoiceMode.whisper => 'OpenAI Whisper',
        VoiceMode.mock => 'Mock (demo)',
      };

  String get subtitle => switch (this) {
        VoiceMode.auto =>
          'Prefer device streaming; fall back to Whisper, then Mock',
        VoiceMode.device => 'Live partials via platform speech recognition',
        VoiceMode.whisper => 'Record → transcribe (listening UI, final on stop)',
        VoiceMode.mock => 'Simulated streaming dictation for demos / tests',
      };
}
