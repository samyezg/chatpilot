import 'dart:async';

import 'package:chatpilot_app/app/router/app_routes.dart';
import 'package:chatpilot_app/app/theme/app_colors.dart';
import 'package:chatpilot_app/app/theme/app_tokens.dart';
import 'package:chatpilot_app/core/widgets/chat_bubble.dart';
import 'package:chatpilot_app/core/widgets/message_input.dart';
import 'package:chatpilot_app/core/widgets/model_selector.dart';
import 'package:chatpilot_app/features/chat/domain/chat_exception.dart';
import 'package:chatpilot_app/features/chat/domain/message.dart';
import 'package:chatpilot_app/features/chat/presentation/chat_providers.dart';
import 'package:chatpilot_app/features/conversations/presentation/conversations_notifier.dart';
import 'package:chatpilot_app/features/persona/domain/persona.dart';
import 'package:chatpilot_app/features/settings/presentation/settings_notifier.dart';
import 'package:chatpilot_app/features/voice/domain/voice_session_state.dart';
import 'package:chatpilot_app/features/voice/presentation/voice_input_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;
  bool _cancelRequested = false;
  String? _streamingId;
  String _streamingText = '';
  String _baseBeforeVoice = '';

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending) return;
    final voice = ref.read(voiceInputProvider);
    if (voice.isBusy) {
      await ref.read(voiceInputProvider.notifier).commit();
    }
    if (!mounted) return;

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final conversation =
        ref.read(conversationByIdProvider(widget.conversationId));
    if (conversation == null) return;

    if (conversation.model.needsApiKey &&
        !ref.read(settingsProvider).hasKeyForModel(conversation.model)) {
      final label = conversation.model.provider;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Add a $label API key in Settings first.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ),
      );
      return;
    }

    final now = DateTime.now().toUtc();
    final userMessage = Message(
      id: 'u-${now.microsecondsSinceEpoch}',
      role: MessageRole.user,
      content: text,
      createdAt: now,
    );

    ref
        .read(conversationsProvider.notifier)
        .appendMessage(widget.conversationId, userMessage);
    _controller.clear();

    final assistantId = 'a-${now.microsecondsSinceEpoch}';
    final placeholder = Message(
      id: assistantId,
      role: MessageRole.assistant,
      content: '',
      createdAt: now.add(const Duration(milliseconds: 1)),
    );
    ref
        .read(conversationsProvider.notifier)
        .appendMessage(widget.conversationId, placeholder);

    setState(() {
      _sending = true;
      _cancelRequested = false;
      _streamingId = assistantId;
      _streamingText = '';
    });
    _scrollToEnd();

    final history = conversation.messages;

    try {
      final stream = ref.read(chatRepositoryProvider).sendMessage(
            model: conversation.model,
            message: text,
            personaId: conversation.personaId,
            history: history,
          );

      await for (final chunk in stream) {
        if (!mounted || _cancelRequested) break;
        setState(() => _streamingText = chunk);
        ref.read(conversationsProvider.notifier).replaceMessage(
              widget.conversationId,
              placeholder.copyWith(content: chunk),
            );
        _scrollToEnd();
      }

      if (_cancelRequested && mounted) {
        final stopped = _streamingText.trim().isEmpty
            ? '_(generation stopped)_'
            : '$_streamingText\n\n_(stopped)_';
        ref.read(conversationsProvider.notifier).replaceMessage(
              widget.conversationId,
              placeholder.copyWith(content: stopped),
            );
      }
    } on ChatException catch (error) {
      if (!mounted || _cancelRequested) return;
      ref.read(conversationsProvider.notifier).replaceMessage(
            widget.conversationId,
            placeholder.copyWith(content: 'Error: ${error.message}'),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted || _cancelRequested) return;
      ref.read(conversationsProvider.notifier).replaceMessage(
            widget.conversationId,
            placeholder.copyWith(content: 'Error: $error'),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
          _cancelRequested = false;
          _streamingId = null;
          _streamingText = '';
        });
      }
    }
  }

  void _stopGeneration() {
    if (!_sending) return;
    setState(() => _cancelRequested = true);
  }

  Future<void> _startVoice() async {
    if (_sending) return;
    _baseBeforeVoice = _controller.text;
    await ref.read(voiceInputProvider.notifier).start();
    final error = ref.read(voiceInputProvider).errorMessage;
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _stopVoice() async {
    final text = await ref.read(voiceInputProvider.notifier).commit();
    _applyVoiceText(text);
  }

  Future<void> _cancelVoice({bool keepPartial = true}) async {
    final partial = ref.read(voiceInputProvider).partialText;
    await ref
        .read(voiceInputProvider.notifier)
        .interrupt(keepPartial: keepPartial);
    if (keepPartial) {
      _applyVoiceText(partial);
    } else {
      _controller.text = _baseBeforeVoice;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  void _applyVoiceText(String spoken) {
    final trimmed = spoken.trim();
    if (trimmed.isEmpty ||
        trimmed == 'Transcribing…' ||
        trimmed.startsWith('…')) {
      _controller.text = _baseBeforeVoice;
    } else if (_baseBeforeVoice.trim().isEmpty) {
      _controller.text = trimmed;
    } else {
      final needsSpace = !_baseBeforeVoice.endsWith(' ') &&
          !_baseBeforeVoice.endsWith('\n');
      _controller.text =
          '$_baseBeforeVoice${needsSpace ? ' ' : ''}$trimmed';
    }
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  void _onTextChanged(String value) {
    final voice = ref.read(voiceInputProvider);
    if (!voice.isListening) return;
    // Typing while listening interrupts capture and keeps current partial.
    unawaited(_cancelVoice(keepPartial: true));
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: AppDurations.fast,
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversation =
        ref.watch(conversationByIdProvider(widget.conversationId));
    final voice = ref.watch(voiceInputProvider);

    ref.listen(voiceInputProvider, (previous, next) {
      if (!next.isListening && next.phase != VoicePhase.processing) return;
      if (next.partialText.isEmpty) return;
      if (next.partialText.startsWith('…') ||
          next.partialText == 'Transcribing…') {
        return;
      }
      _applyVoiceText(next.partialText);
    });

    ref.listen(voiceInputProvider, (previous, next) {
      if (previous?.errorMessage == next.errorMessage) return;
      final error = next.errorMessage;
      if (error == null || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    });

    if (conversation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Conversation not found'),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Back to list'),
              ),
            ],
          ),
        ),
      );
    }

    final persona = Persona.byId(conversation.personaId);
    final title = conversation.title;
    final listening = voice.isListening || voice.phase == VoicePhase.processing;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18)),
            Text(
              listening
                  ? 'Listening · ${voice.engineLabel.isEmpty ? 'Voice' : voice.engineLabel}'
                  : persona == null
                      ? conversation.model.label
                      : '${persona.icon} ${persona.name}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: listening ? AppColors.primary : AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        actions: [
          if (listening)
            TextButton(
              key: const ValueKey('voice-cancel'),
              onPressed: () => _cancelVoice(keepPartial: false),
              child: const Text('Cancel'),
            ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ModelSelector(
              value: conversation.model,
              onChanged: (model) {
                ref
                    .read(conversationsProvider.notifier)
                    .setModel(conversation.id, model);
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: conversation.messages.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final message = conversation.messages[index];
                final streaming = message.id == _streamingId;
                return ChatBubble(
                  key: ValueKey(message.id),
                  role: message.role,
                  text: streaming ? _streamingText : message.content,
                  isStreaming: streaming,
                );
              },
            ),
          ),
          const Divider(height: 1),
          ColoredBox(
            color: AppColors.surface,
            child: MessageInput(
              controller: _controller,
              enabled: !_sending,
              isListening: listening,
              isSending: _sending,
              onSend: _send,
              onMic: _startVoice,
              onStopVoice: _stopVoice,
              onStopGeneration: _stopGeneration,
              onTextChanged: _onTextChanged,
            ),
          ),
        ],
      ),
    );
  }
}
