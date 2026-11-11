enum AuthEmailIssue { empty, invalid }

enum AuthPasswordIssue { empty, tooShort }

abstract final class AuthValidators {
  static AuthEmailIssue? emailIssue(String value) {
    final email = value.trim();
    if (email.isEmpty) return AuthEmailIssue.empty;
    if (!email.contains('@') || !email.contains('.')) {
      return AuthEmailIssue.invalid;
    }
    return null;
  }

  static AuthPasswordIssue? passwordIssue(String value) {
    if (value.isEmpty) return AuthPasswordIssue.empty;
    if (value.length < 6) return AuthPasswordIssue.tooShort;
    return null;
  }

  /// Legacy English helpers kept for older call sites / tests.
  static String? emailError(String value) {
    return switch (emailIssue(value)) {
      AuthEmailIssue.empty => 'Enter your email.',
      AuthEmailIssue.invalid => 'Enter a valid email.',
      null => null,
    };
  }

  static String? passwordError(String value) {
    return switch (passwordIssue(value)) {
      AuthPasswordIssue.empty => 'Enter your password.',
      AuthPasswordIssue.tooShort => 'Use at least 6 characters.',
      null => null,
    };
  }
}
