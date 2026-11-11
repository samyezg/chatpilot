import 'package:chatpilot_app/app/router/app_routes.dart';
import 'package:chatpilot_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:chatpilot_app/features/auth/presentation/pages/sign_up_page.dart';
import 'package:chatpilot_app/features/chat/presentation/pages/chat_page.dart';
import 'package:chatpilot_app/features/conversations/presentation/pages/conversation_list_page.dart';
import 'package:chatpilot_app/features/persona/presentation/pages/persona_picker_page.dart';
import 'package:chatpilot_app/features/settings/presentation/pages/settings_page.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.conversations,
    routes: [
      GoRoute(
        path: AppRoutes.conversations,
        name: 'conversations',
        builder: (context, state) => const ConversationListPage(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'demo';
          return ChatPage(conversationId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.persona,
        name: 'persona',
        builder: (context, state) => const PersonaPickerPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        name: 'signIn',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        name: 'signUp',
        builder: (context, state) => const SignUpPage(),
      ),
    ],
  );
}
