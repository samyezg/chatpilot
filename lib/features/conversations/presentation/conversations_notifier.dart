import 'dart:ui' show PlatformDispatcher;

import 'package:chatpilot_app/app/config/app_environment_provider.dart';
import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:chatpilot_app/features/chat/domain/message.dart';
import 'package:chatpilot_app/features/conversations/data/in_memory_conversations_repository.dart';
import 'package:chatpilot_app/features/conversations/data/local_conversations_repository.dart';
import 'package:chatpilot_app/features/conversations/data/mock_conversations_seed.dart';
import 'package:chatpilot_app/features/conversations/data/supabase_conversations_sync.dart';
import 'package:chatpilot_app/features/conversations/data/syncing_conversations_repository.dart';
import 'package:chatpilot_app/features/conversations/domain/conversation.dart';
import 'package:chatpilot_app/features/conversations/domain/conversations_repository.dart';
import 'package:chatpilot_app/features/persona/domain/persona.dart';
import 'package:chatpilot_app/features/settings/presentation/settings_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String _seedLanguageCode(Ref ref) {
  final preference = ref.watch(settingsProvider).localePreference;
  return resolveAppLanguageCode(
    localePreference: preference,
    platformLocale: PlatformDispatcher.instance.locale,
  );
}

final conversationsRepositoryProvider = Provider<ConversationsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).asData?.value;
  if (prefs == null) {
    return InMemoryConversationsRepository(seed: const []);
  }
  ref.keepAlive();
  final languageCode = _seedLanguageCode(ref);
  final local = LocalConversationsRepository.load(
    prefs,
    seedIfEmpty: buildMockConversations(languageCode: languageCode),
  );
  final env = ref.watch(appEnvironmentProvider);
  if (!env.useSupabase) return local;
  return SyncingConversationsRepository(
    local: local,
    sync: SupabaseConversationsSync(Supabase.instance.client),
  );
});

final conversationsReadyProvider = Provider<bool>((ref) {
  return ref.watch(sharedPreferencesProvider).hasValue;
});

class ConversationsNotifier extends Notifier<List<Conversation>> {
  ConversationsRepository get _repo =>
      ref.read(conversationsRepositoryProvider);

  @override
  List<Conversation> build() {
    ref.watch(sharedPreferencesProvider);
    ref.watch(appEnvironmentProvider);
    return ref.watch(conversationsRepositoryProvider).list();
  }

  void refresh() => state = _repo.list();

  Conversation? getById(String id) => _repo.getById(id);

  Conversation createFromPersona(String personaId, {String? title}) {
    final persona = Persona.presets.firstWhere(
      (p) => p.id == personaId,
      orElse: () => Persona.presets.first,
    );
    final created = _repo.create(
      personaId: persona.id,
      title: (title == null || title.trim().isEmpty) ? persona.name : title.trim(),
      model: AiModel.mock,
    );
    refresh();
    return created;
  }

  void delete(String id) {
    _repo.delete(id);
    refresh();
  }

  void rename(String id, String title) {
    _repo.rename(id, title);
    refresh();
  }

  void setModel(String id, AiModel model) {
    _repo.setModel(id, model);
    refresh();
  }

  void appendMessage(String conversationId, Message message) {
    _repo.appendMessage(conversationId, message);
    refresh();
  }

  void replaceMessage(String conversationId, Message message) {
    _repo.replaceMessage(conversationId, message);
    refresh();
  }

  Future<void> resetToDemoSeed() async {
    final seed = buildMockConversations(languageCode: _seedLanguageCode(ref));
    final repo = _repo;
    if (repo is SyncingConversationsRepository) {
      await repo.clearAndReseed(seed);
    } else if (repo is LocalConversationsRepository) {
      await repo.clearAndReseed(seed);
    }
    refresh();
  }

  Future<void> syncFromCloud() async {
    final repo = _repo;
    if (repo is SyncingConversationsRepository) {
      await repo.pullAndMerge();
      refresh();
    }
  }
}

final conversationsProvider =
    NotifierProvider<ConversationsNotifier, List<Conversation>>(
  ConversationsNotifier.new,
);

final conversationByIdProvider =
    Provider.family<Conversation?, String>((ref, id) {
  ref.watch(conversationsProvider);
  return ref.read(conversationsProvider.notifier).getById(id);
});
