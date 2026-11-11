import 'package:chatpilot_app/features/auth/domain/auth_exception.dart';
import 'package:chatpilot_app/features/auth/domain/auth_repository.dart';
import 'package:chatpilot_app/features/auth/domain/auth_user.dart';
import 'package:chatpilot_app/features/auth/domain/auth_validators.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthException, AuthUser;

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  AuthUser? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return AuthUser(id: user.id, email: user.email ?? '');
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    _assertCredentials(email, password);
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthException('Could not sign in. Try again.');
      }
      return AuthUser(
        id: user.id,
        email: user.email ?? email.trim().toLowerCase(),
      );
    } on AuthException {
      rethrow;
    } on AuthApiException catch (error) {
      throw AuthException(error.message);
    } catch (_) {
      throw const AuthException('Could not sign in. Check your connection.');
    }
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    _assertCredentials(email, password);
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthException(
          'Account created. Confirm your email before signing in.',
        );
      }
      if (_client.auth.currentSession == null) {
        throw const AuthException(
          'Check your inbox to confirm email, then sign in.',
        );
      }
      return AuthUser(
        id: user.id,
        email: user.email ?? email.trim().toLowerCase(),
      );
    } on AuthException {
      rethrow;
    } on AuthApiException catch (error) {
      throw AuthException(error.message);
    } catch (_) {
      throw const AuthException('Could not create account. Try again.');
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  void _assertCredentials(String email, String password) {
    final emailError = AuthValidators.emailError(email);
    if (emailError != null) throw AuthException(emailError);
    final passwordError = AuthValidators.passwordError(password);
    if (passwordError != null) throw AuthException(passwordError);
  }
}
