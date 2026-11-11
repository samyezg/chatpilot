abstract final class AppRoutes {
  static const String conversations = '/';
  static const String chat = '/chat/:id';
  static const String persona = '/persona';
  static const String settings = '/settings';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';

  static String chatPath(String id) => '/chat/$id';
}
