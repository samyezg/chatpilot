import 'package:chatpilot_app/features/auth/data/fake_auth_repository.dart';
import 'package:chatpilot_app/features/auth/domain/auth_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sign up then sign in', () async {
    final repo = FakeAuthRepository();
    final created = await repo.signUp(
      email: 'a@b.com',
      password: 'secret1',
    );
    expect(created.email, 'a@b.com');

    await repo.signOut();
    expect(repo.currentUser, isNull);

    final again = await repo.signIn(email: 'a@b.com', password: 'secret1');
    expect(again.id, created.id);
  });

  test('rejects bad password', () async {
    final repo = FakeAuthRepository();
    await repo.signUp(email: 'a@b.com', password: 'secret1');
    await repo.signOut();
    await expectLater(
      repo.signIn(email: 'a@b.com', password: 'wrong1'),
      throwsA(isA<AuthException>()),
    );
  });
}
