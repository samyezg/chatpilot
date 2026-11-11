import 'dart:async';

import 'package:chatpilot_app/features/voice/domain/stt_update.dart';
import 'package:chatpilot_app/features/voice/domain/voice_exception.dart';
import 'package:chatpilot_app/features/voice/domain/voice_session_state.dart';
import 'package:chatpilot_app/features/voice/presentation/voice_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceInputController extends Notifier<VoiceSessionState> {
  StreamSubscription<SttUpdate>? _subscription;

  @override
  VoiceSessionState build() {
    ref.onDispose(() {
      unawaited(_subscription?.cancel());
    });
    return const VoiceSessionState();
  }

  Future<void> start({String? localeId}) async {
    final engine = ref.read(streamingSttEngineProvider);
    if (state.isBusy) {
      await interrupt(keepPartial: true);
    }

    state = state.copyWith(
      phase: VoicePhase.listening,
      partialText: '',
      engineLabel: engine.label,
      clearError: true,
    );

    try {
      final stream = engine.start(localeId: localeId);
      await _subscription?.cancel();
      _subscription = stream.listen(
        (update) {
          final cleaned = _visiblePartial(update.text);
          state = state.copyWith(
            phase: update.isFinal ? VoicePhase.idle : VoicePhase.listening,
            partialText: cleaned,
            engineLabel: engine.label,
            clearError: true,
          );
        },
        onError: (Object error) {
          state = state.copyWith(
            phase: VoicePhase.error,
            errorMessage: error is VoiceException
                ? error.message
                : error.toString(),
          );
        },
        onDone: () {
          if (state.phase == VoicePhase.listening ||
              state.phase == VoicePhase.processing) {
            state = state.copyWith(phase: VoicePhase.idle);
          }
        },
      );
    } catch (error) {
      state = state.copyWith(
        phase: VoicePhase.error,
        errorMessage:
            error is VoiceException ? error.message : error.toString(),
      );
    }
  }

  /// Stop capture and keep the latest partial as committed text.
  Future<String> commit() async {
    final engine = ref.read(streamingSttEngineProvider);
    final kept = state.partialText;
    state = state.copyWith(phase: VoicePhase.processing);
    try {
      await engine.stop().timeout(const Duration(seconds: 60));
    } catch (_) {
      // Engine / stream may already be closed.
    }
    // Let listen callbacks apply the final transcript (esp. Whisper).
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await _subscription?.cancel();
    _subscription = null;
    final text = state.partialText.trim().isEmpty
        ? kept.trim()
        : state.partialText.trim();
    final cleaned = _finalizeText(text, kept);
    state = state.copyWith(
      phase: VoicePhase.idle,
      partialText: cleaned,
      clearError: true,
    );
    return cleaned;
  }

  /// Abort listening; optionally keep the current partial in state.
  Future<void> interrupt({bool keepPartial = false}) async {
    final kept = keepPartial ? state.partialText : '';
    try {
      await ref.read(streamingSttEngineProvider).cancel();
    } catch (_) {}
    await _subscription?.cancel();
    _subscription = null;
    state = state.copyWith(
      phase: VoicePhase.idle,
      partialText: kept,
      clearError: true,
    );
  }

  String _visiblePartial(String text) {
    if (text == 'Transcribing…') return text;
    if (text.startsWith('…')) return text;
    return text;
  }

  String _finalizeText(String text, String fallback) {
    if (text == 'Transcribing…' || text.startsWith('…')) {
      return fallback.trim();
    }
    return text.trim();
  }
}

final voiceInputProvider =
    NotifierProvider<VoiceInputController, VoiceSessionState>(
  VoiceInputController.new,
);
