abstract final class AuthValidators {
  static String? emailError(String value) {
    final email = value.trim();
    if (email.isEmpty) return 'Enter your email.';
    if (!email.contains('@') || !email.contains('.')) {
      return 'Enter a valid email.';
    }
    return null;
  }

  static String? passwordError(String value) {
    if (value.isEmpty) return 'Enter your password.';
    if (value.length < 6) return 'Use at least 6 characters.';
    return null;
  }
}
