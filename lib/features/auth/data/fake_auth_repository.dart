import 'package:chatpilot_app/features/auth/domain/auth_exception.dart';
import 'package:chatpilot_app/features/auth/domain/auth_repository.dart';
import 'package:chatpilot_app/features/auth/domain/auth_user.dart';
import 'package:chatpilot_app/features/auth/domain/auth_validators.dart';

class FakeAuthRepository implements AuthRepository {
  final Map<String, String> _users = {};
  AuthUser? _current;

  @override
  AuthUser? get currentUser => _current;

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    _assert(email, password);
    final key = email.trim().toLowerCase();
    final stored = _users[key];
    if (stored == null || stored != password) {
      throw const AuthException('Invalid email or password.');
    }
    _current = AuthUser(id: 'fake-$key', email: key);
    return _current!;
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    _assert(email, password);
    final key = email.trim().toLowerCase();
    if (_users.containsKey(key)) {
      throw const AuthException('Account already exists. Sign in instead.');
    }
    _users[key] = password;
    _current = AuthUser(id: 'fake-$key', email: key);
    return _current!;
  }

  @override
  Future<void> signOut() async {
    _current = null;
  }

  void _assert(String email, String password) {
    final emailError = AuthValidators.emailError(email);
    if (emailError != null) throw AuthException(emailError);
    final passwordError = AuthValidators.passwordError(password);
    if (passwordError != null) throw AuthException(passwordError);
  }
}
