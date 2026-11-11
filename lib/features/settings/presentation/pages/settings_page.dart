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
import 'package:chatpilot_app/l10n/l10n_ext.dart';
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
        SnackBar(content: Text(context.l10n.apiKeySaved(provider.label))),
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
      SnackBar(content: Text(context.l10n.apiKeyCleared(provider.label))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            l10n.language,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.languageSectionHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontFamily: AppFonts.secondary,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            key: const ValueKey('locale-preference'),
            // ignore: deprecated_member_use
            value: settings.localePreference,
            decoration: InputDecoration(labelText: l10n.language),
            items: [
              DropdownMenuItem(value: '', child: Text(l10n.languageSystem)),
              DropdownMenuItem(value: 'en', child: Text(l10n.languageEnglish)),
              DropdownMenuItem(value: 'zh', child: Text(l10n.languageChinese)),
            ],
            onChanged: (value) async {
              if (value == null) return;
              await ref
                  .read(settingsProvider.notifier)
                  .setLocalePreference(value);
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.accountAndSync,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            supabaseOn
                ? l10n.supabaseConfigured
                : l10n.supabaseNotConfigured,
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
              child: Text(l10n.signIn),
            )
          else ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(user.email),
              subtitle: Text(
                supabaseOn ? l10n.cloudSyncOn : l10n.localFakeSession,
              ),
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
                        SnackBar(content: Text(l10n.syncFinished)),
                      );
                    },
                    child: Text(l10n.syncNow),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).signOut();
                  },
                  child: Text(l10n.signOut),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.apiKeys,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.apiKeysHint,
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
                  setState(
                    () => _obscure[provider] = !(_obscure[provider] ?? true),
                  );
                },
                onSave: () => _save(provider),
                onClear: () => _clear(provider),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          Text(
            l10n.voiceDictationSection,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.voiceDictationHint,
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
            decoration: InputDecoration(labelText: l10n.voiceEngine),
            items: [
              for (final mode in VoiceMode.values)
                DropdownMenuItem(
                  value: mode,
                  child: Text(l10n.voiceModeLabel(mode)),
                ),
            ],
            onChanged: (mode) async {
              if (mode == null) return;
              await ref.read(settingsProvider.notifier).setVoiceMode(mode);
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.voiceModeSubtitle(settings.voiceMode),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.localData,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.localDataHint,
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
                SnackBar(content: Text(l10n.resetDemoDone)),
              );
            },
            child: Text(l10n.resetDemo),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.modelsSection,
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
                        ? l10n.modelStatusLiveKeyPresent(model.provider)
                        : l10n.modelStatusLiveAddKey(model.provider)
                    : l10n.modelStatusOfflineMock(model.provider),
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
    final l10n = context.l10n;
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
            labelText: l10n.apiKeyLabel(provider.label),
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
                child: Text(saving ? l10n.saving : l10n.saveKey),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            OutlinedButton(
              onPressed: hasKey ? onClear : null,
              child: Text(l10n.clear),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          hasKey ? l10n.statusKeyPresent : l10n.statusNoKey,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
