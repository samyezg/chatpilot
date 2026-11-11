enum VoicePhase {
  idle,
  listening,
  processing,
  error,
}

class VoiceSessionState {
  const VoiceSessionState({
    this.phase = VoicePhase.idle,
    this.partialText = '',
    this.engineLabel = '',
    this.errorMessage,
  });

  final VoicePhase phase;
  final String partialText;
  final String engineLabel;
  final String? errorMessage;

  bool get isListening => phase == VoicePhase.listening;
  bool get isBusy =>
      phase == VoicePhase.listening || phase == VoicePhase.processing;

  VoiceSessionState copyWith({
    VoicePhase? phase,
    String? partialText,
    String? engineLabel,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VoiceSessionState(
      phase: phase ?? this.phase,
      partialText: partialText ?? this.partialText,
      engineLabel: engineLabel ?? this.engineLabel,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
