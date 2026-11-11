import 'package:chatpilot_app/app/chatpilot_app.dart';
import 'package:chatpilot_app/app/config/app_environment.dart';
import 'package:chatpilot_app/app/config/app_environment_provider.dart';
import 'package:chatpilot_app/features/conversations/data/local_conversations_repository.dart';
import 'package:chatpilot_app/features/conversations/data/supabase_conversations_sync.dart';
import 'package:chatpilot_app/features/conversations/data/syncing_conversations_repository.dart';
import 'package:chatpilot_app/features/conversations/domain/conversations_repository.dart';
import 'package:chatpilot_app/features/conversations/presentation/conversations_notifier.dart';
import 'package:chatpilot_app/features/settings/presentation/settings_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final env = AppEnvironment.fromDefines();
  if (env.useSupabase) {
    await Supabase.initialize(
      url: env.supabaseUrl!,
      publishableKey: env.supabaseAnonKey!,
    );
  }

  final prefs = await SharedPreferences.getInstance();
  final local = LocalConversationsRepository.load(prefs);
  final ConversationsRepository conversations = env.useSupabase
      ? SyncingConversationsRepository(
          local: local,
          sync: SupabaseConversationsSync(Supabase.instance.client),
        )
      : local;

  runApp(
    ProviderScope(
      overrides: [
        appEnvironmentProvider.overrideWithValue(env),
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
        conversationsRepositoryProvider.overrideWithValue(conversations),
      ],
      child: ChatPilotApp(),
    ),
  );
}
