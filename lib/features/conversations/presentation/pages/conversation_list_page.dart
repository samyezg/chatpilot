import 'package:chatpilot_app/app/config/app_environment_provider.dart';
import 'package:chatpilot_app/app/router/app_routes.dart';
import 'package:chatpilot_app/app/theme/app_colors.dart';
import 'package:chatpilot_app/app/theme/app_tokens.dart';
import 'package:chatpilot_app/core/utils/relative_time.dart';
import 'package:chatpilot_app/features/auth/presentation/auth_notifier.dart';
import 'package:chatpilot_app/features/conversations/domain/conversation.dart';
import 'package:chatpilot_app/features/conversations/presentation/conversations_notifier.dart';
import 'package:chatpilot_app/features/persona/domain/persona.dart';
import 'package:chatpilot_app/l10n/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ConversationListPage extends ConsumerWidget {
  const ConversationListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ready = ref.watch(conversationsReadyProvider);
    final conversations = ref.watch(conversationsProvider);
    final signedIn = ref.watch(isSignedInProvider);
    final supabaseOn = ref.watch(appEnvironmentProvider).useSupabase;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            key: const ValueKey('open-settings'),
            tooltip: l10n.settings,
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('new-chat'),
        onPressed: () => context.push(AppRoutes.persona),
        icon: const Icon(Icons.add),
        label: Text(l10n.newChat),
      ),
      body: !ready
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (supabaseOn && !signedIn) const _SyncBanner(),
                Expanded(
                  child: conversations.isEmpty
                      ? const _EmptyConversations()
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 96),
                          itemCount: conversations.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final conversation = conversations[index];
                            return _ConversationTile(
                              conversation: conversation,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _SyncBanner extends StatelessWidget {
  const _SyncBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.cloud_off_outlined, color: AppColors.primary),
        title: Text(l10n.localOnlyBanner),
        trailing: TextButton(
          onPressed: () => context.push(AppRoutes.signIn),
          child: Text(l10n.signIn),
        ),
      ),
    );
  }
}

class _EmptyConversations extends StatelessWidget {
  const _EmptyConversations();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.forum_outlined, size: 48, color: AppColors.primary),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.noConversationsTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.noConversationsBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontFamily: AppFonts.secondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends ConsumerWidget {
  const _ConversationTile({required this.conversation});

  final Conversation conversation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final persona = Persona.byId(conversation.personaId);

    return Dismissible(
      key: ValueKey('dismiss-${conversation.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: AppColors.error,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(conversationsProvider.notifier).delete(conversation.id);
      },
      child: ListTile(
        key: ValueKey(conversation.id),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Text(persona?.icon ?? '💬', style: const TextStyle(fontSize: 18)),
        ),
        title: Text(
          conversation.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          conversation.preview,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontFamily: AppFonts.secondary,
          ),
        ),
        trailing: Text(
          formatRelativeTime(conversation.updatedAt, l10n: l10n),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        onTap: () => context.push(AppRoutes.chatPath(conversation.id)),
        onLongPress: () => _rename(context, ref),
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: conversation.title);
    final next = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.renameConversation),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.title),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (next == null) return;
    ref.read(conversationsProvider.notifier).rename(conversation.id, next);
  }
}
