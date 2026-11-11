import 'package:chatpilot_app/app/config/app_environment_provider.dart';
import 'package:chatpilot_app/features/auth/data/fake_auth_repository.dart';
import 'package:chatpilot_app/features/auth/data/supabase_auth_repository.dart';
import 'package:chatpilot_app/features/auth/domain/auth_repository.dart';
import 'package:chatpilot_app/features/auth/domain/auth_user.dart';
import 'package:chatpilot_app/features/conversations/presentation/conversations_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final env = ref.watch(appEnvironmentProvider);
  if (env.useSupabase) {
    return SupabaseAuthRepository(Supabase.instance.client);
  }
  return FakeAuthRepository();
});

class AuthNotifier extends Notifier<AuthUser?> {
  @override
  AuthUser? build() {
    return ref.read(authRepositoryProvider).currentUser;
  }

  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final user = await ref.read(authRepositoryProvider).signIn(
          email: email,
          password: password,
        );
    state = user;
    await ref.read(conversationsProvider.notifier).syncFromCloud();
    return user;
  }

  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    final user = await ref.read(authRepositoryProvider).signUp(
          email: email,
          password: password,
        );
    state = user;
    await ref.read(conversationsProvider.notifier).syncFromCloud();
    return user;
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = null;
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthUser?>(AuthNotifier.new);

final isSignedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) != null;
});
