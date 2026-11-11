import 'package:chatpilot_app/app/theme/app_colors.dart';
import 'package:chatpilot_app/app/theme/app_tokens.dart';
import 'package:chatpilot_app/features/chat/domain/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.role,
    required this.text,
    this.isStreaming = false,
  });

  final MessageRole role;
  final String text;
  final bool isStreaming;

  bool get _isUser => role == MessageRole.user;

  Future<void> _copy(BuildContext context) async {
    if (text.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = _isUser ? AppColors.userBubble : AppColors.assistantBubble;
    final fg = _isUser ? AppColors.textOnUserBubble : AppColors.textPrimary;
    final display = isStreaming && text.isEmpty ? '…' : text;

    return Align(
      alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.bubble),
            topRight: const Radius.circular(AppRadius.bubble),
            bottomLeft:
                Radius.circular(_isUser ? AppRadius.bubble : AppRadius.sm),
            bottomRight:
                Radius.circular(_isUser ? AppRadius.sm : AppRadius.bubble),
          ),
          child: InkWell(
            onLongPress: () => _copy(context),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppRadius.bubble),
              topRight: const Radius.circular(AppRadius.bubble),
              bottomLeft:
                  Radius.circular(_isUser ? AppRadius.bubble : AppRadius.sm),
              bottomRight:
                  Radius.circular(_isUser ? AppRadius.sm : AppRadius.bubble),
            ),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadius.bubble),
                  topRight: const Radius.circular(AppRadius.bubble),
                  bottomLeft: Radius.circular(
                    _isUser ? AppRadius.bubble : AppRadius.sm,
                  ),
                  bottomRight: Radius.circular(
                    _isUser ? AppRadius.sm : AppRadius.bubble,
                  ),
                ),
                border: _isUser ? null : Border.all(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: _isUser
                    ? Text(
                        display,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: fg,
                              height: 1.4,
                              fontFamily: AppFonts.secondary,
                            ),
                      )
                    : MarkdownBody(
                        data: display,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet.fromTheme(
                          Theme.of(context),
                        ).copyWith(
                          p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: fg,
                                height: 1.4,
                                fontFamily: AppFonts.secondary,
                              ),
                          code: TextStyle(
                            fontFamily: AppFonts.code,
                            backgroundColor: AppColors.surfaceVariant,
                            color: AppColors.textPrimary,
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
