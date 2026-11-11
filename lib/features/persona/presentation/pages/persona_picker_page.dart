import 'package:chatpilot_app/app/router/app_routes.dart';
import 'package:chatpilot_app/app/theme/app_tokens.dart';
import 'package:chatpilot_app/core/widgets/persona_card.dart';
import 'package:chatpilot_app/features/conversations/presentation/conversations_notifier.dart';
import 'package:chatpilot_app/features/persona/domain/persona.dart';
import 'package:chatpilot_app/l10n/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PersonaPickerPage extends ConsumerStatefulWidget {
  const PersonaPickerPage({super.key});

  @override
  ConsumerState<PersonaPickerPage> createState() => _PersonaPickerPageState();
}

class _PersonaPickerPageState extends ConsumerState<PersonaPickerPage> {
  String _selectedId = Persona.presets.first.id;

  void _start() {
    final created = ref.read(conversationsProvider.notifier).createFromPersona(
          _selectedId,
          title: context.l10n.personaName(_selectedId),
        );
    context.go(AppRoutes.chatPath(created.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.choosePersona)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          for (final persona in Persona.presets) ...[
            PersonaCard(
              persona: persona,
              selected: persona.id == _selectedId,
              onTap: () => setState(() => _selectedId = persona.id),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            key: const ValueKey('start-chat-with-persona'),
            onPressed: _start,
            child: Text(l10n.startChat),
          ),
        ],
      ),
    );
  }
}
