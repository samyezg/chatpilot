import 'package:chatpilot_app/app/config/app_environment_provider.dart';
import 'package:chatpilot_app/app/router/app_routes.dart';
import 'package:chatpilot_app/app/theme/app_colors.dart';
import 'package:chatpilot_app/app/theme/app_tokens.dart';
import 'package:chatpilot_app/features/auth/presentation/auth_notifier.dart';
import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/conversations/presentation/conversations_notifier.dart';
import 'package:chatpilot_app/features/settings/data/api_key_provider.dart';
import 'package:chatpilot_app/features/settings/presentation/settings_notifier.dart';
import 'package:chatpilot_app/features/voice/domain/voice_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _controllers = <ApiKeyProvider, TextEditingController>{};
  final _obscure = <ApiKeyProvider, bool>{};
  var _savingProvider = ApiKeyProvider.deepseek;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    for (final provider in ApiKeyProvider.values) {
      _controllers[provider] = TextEditingController(
        text: settings.keyFor(provider) ?? '',
      );
      _obscure[provider] = true;
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save(ApiKeyProvider provider) async {
    setState(() {
      _saving = true;
      _savingProvider = provider;
    });
    try {
      await ref
          .read(settingsProvider.notifier)
          .saveKey(provider, _controllers[provider]!.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${provider.label} API key saved on this device')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _clear(ApiKeyProvider provider) async {
    await ref.read(settingsProvider.notifier).clearKey(provider);
    _controllers[provider]?.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${provider.label} API key cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final prefsAsync = ref.watch(sharedPreferencesProvider);
    final user = ref.watch(authProvider);
    final supabaseOn = ref.watch(appEnvironmentProvider).useSupabase;

    ref.listen(settingsProvider, (previous, next) {
      for (final provider in ApiKeyProvider.values) {
        final controller = _controllers[provider];
        if (controller == null) continue;
        final key = next.keyFor(provider) ?? '';
        if (controller.text.isEmpty && key.isNotEmpty) {
          controller.text = key;
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            'Account & sync',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            supabaseOn
                ? 'Supabase is configured. Sign in to sync conversations across devices.'
                : 'Supabase not configured (local Fake Auth). Pass --dart-define-from-file=.vscode/supabase.local.json to enable cloud sync.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontFamily: AppFonts.secondary,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (user == null)
            FilledButton(
              key: const ValueKey('settings-sign-in'),
              onPressed: () => context.push(AppRoutes.signIn),
              child: const Text('Sign in'),
            )
          else ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(user.email),
              subtitle: Text(supabaseOn ? 'Cloud sync on' : 'Local fake session'),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const ValueKey('sync-now'),
                    onPressed: () async {
                      await ref
                          .read(conversationsProvider.notifier)
                          .syncFromCloud();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sync finished')),
                      );
                    },
                    child: const Text('Sync now'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).signOut();
                  },
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Text(
            'API keys',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Keys stay in local SharedPreferences only — never bundled or committed. '
            'Each live model needs its own provider key.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontFamily: AppFonts.secondary,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (prefsAsync.isLoading)
            const LinearProgressIndicator()
          else
            for (final provider in ApiKeyProvider.values) ...[
              _ApiKeyField(
                provider: provider,
                controller: _controllers[provider]!,
                obscure: _obscure[provider] ?? true,
                hasKey: settings.hasKey(provider),
                saving: _saving && _savingProvider == provider,
                onToggleObscure: () {
                  setState(() => _obscure[provider] = !(_obscure[provider] ?? true));
                },
                onSave: () => _save(provider),
                onClear: () => _clear(provider),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          Text(
            'Voice dictation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Streaming dictation with interrupt. Auto prefers device STT, then OpenAI Whisper, then Mock.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontFamily: AppFonts.secondary,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<VoiceMode>(
            key: const ValueKey('voice-mode'),
            // ignore: deprecated_member_use
            value: settings.voiceMode,
            decoration: const InputDecoration(labelText: 'Voice engine'),
            items: [
              for (final mode in VoiceMode.values)
                DropdownMenuItem(
                  value: mode,
                  child: Text(mode.label),
                ),
            ],
            onChanged: (mode) async {
              if (mode == null) return;
              await ref.read(settingsProvider.notifier).setVoiceMode(mode);
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            settings.voiceMode.subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Local data',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Conversations are saved on this device (SharedPreferences). Restart keeps your chats.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontFamily: AppFonts.secondary,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            key: const ValueKey('reset-conversations'),
            onPressed: () async {
              await ref.read(conversationsProvider.notifier).resetToDemoSeed();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reset to demo conversations')),
              );
            },
            child: const Text('Reset to demo conversations'),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Models',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final model in AiModel.values)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(model.label),
              subtitle: Text(
                model.needsApiKey
                    ? settings.hasKeyForModel(model)
                        ? '${model.provider} · live SSE · key present'
                        : '${model.provider} · live SSE · add key to use'
                    : '${model.provider} · offline mock stream',
              ),
              trailing: Icon(
                model.needsApiKey
                    ? (settings.hasKeyForModel(model)
                        ? Icons.check_circle_outline
                        : Icons.key_off_outlined)
                    : Icons.check_circle_outline,
                color: model.needsApiKey && !settings.hasKeyForModel(model)
                    ? AppColors.textSecondary
                    : AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}

class _ApiKeyField extends StatelessWidget {
  const _ApiKeyField({
    required this.provider,
    required this.controller,
    required this.obscure,
    required this.hasKey,
    required this.saving,
    required this.onToggleObscure,
    required this.onSave,
    required this.onClear,
  });

  final ApiKeyProvider provider;
  final TextEditingController controller;
  final bool obscure;
  final bool hasKey;
  final bool saving;
  final VoidCallback onToggleObscure;
  final VoidCallback onSave;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          provider.label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          key: ValueKey('${provider.name}-api-key'),
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: '${provider.label} API key',
            hintText: provider.hint,
            suffixIcon: IconButton(
              onPressed: onToggleObscure,
              icon: Icon(
                obscure ? Icons.visibility_outlined : Icons.visibility_off,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                key: ValueKey('save-${provider.name}-key'),
                onPressed: saving ? null : onSave,
                child: Text(saving ? 'Saving…' : 'Save key'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            OutlinedButton(
              onPressed: hasKey ? onClear : null,
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          hasKey
              ? 'Status: key present'
              : 'Status: no key',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
