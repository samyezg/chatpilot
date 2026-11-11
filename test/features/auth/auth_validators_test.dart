import 'package:chatpilot_app/features/auth/domain/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validates email and password', () {
    expect(AuthValidators.emailError(''), isNotNull);
    expect(AuthValidators.emailError('a@b.com'), isNull);
    expect(AuthValidators.passwordError('123'), isNotNull);
    expect(AuthValidators.passwordError('secret1'), isNull);
  });
}
