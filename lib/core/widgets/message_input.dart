import 'package:chatpilot_app/app/theme/app_colors.dart';
import 'package:chatpilot_app/app/theme/app_tokens.dart';
import 'package:flutter/material.dart';

class MessageInput extends StatelessWidget {
  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.onMic,
    this.onStopVoice,
    this.onStopGeneration,
    this.onTextChanged,
    this.enabled = true,
    this.isListening = false,
    this.isSending = false,
    this.hintText = 'Message…',
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onMic;
  final VoidCallback? onStopVoice;
  final VoidCallback? onStopGeneration;
  final ValueChanged<String>? onTextChanged;
  final bool enabled;
  final bool isListening;
  final bool isSending;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            if (onMic != null || onStopVoice != null) ...[
              SizedBox(
                width: AppSizes.sendButton,
                height: AppSizes.sendButton,
                child: isListening
                    ? FilledButton(
                        key: const ValueKey('voice-stop'),
                        onPressed: onStopVoice,
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: const CircleBorder(),
                          backgroundColor: AppColors.error,
                        ),
                        child: const Icon(Icons.stop_rounded, size: 22),
                      )
                    : IconButton(
                        key: const ValueKey('voice-mic'),
                        onPressed: enabled && !isSending ? onMic : null,
                        style: IconButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                        icon: const Icon(Icons.mic_none_rounded),
                        tooltip: 'Voice dictation',
                      ),
              ),
              const SizedBox(width: AppSpacing.xxs),
            ],
            Expanded(
              child: TextField(
                key: const ValueKey('message-input'),
                controller: controller,
                enabled: enabled && !isListening,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (!isSending) onSend();
                },
                onChanged: onTextChanged,
                decoration: InputDecoration(
                  hintText: isListening ? 'Listening…' : hintText,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            SizedBox(
              width: AppSizes.sendButton,
              height: AppSizes.sendButton,
              child: isSending
                  ? FilledButton(
                      key: const ValueKey('message-stop'),
                      onPressed: onStopGeneration,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const CircleBorder(),
                        backgroundColor: AppColors.error,
                      ),
                      child: const Icon(Icons.stop_rounded, size: 22),
                    )
                  : FilledButton(
                      key: const ValueKey('message-send'),
                      onPressed: enabled && !isListening ? onSend : null,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const CircleBorder(),
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Icon(Icons.arrow_upward_rounded, size: 22),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
