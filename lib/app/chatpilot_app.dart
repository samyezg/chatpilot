import 'package:chatpilot_app/app/router/app_router.dart';
import 'package:chatpilot_app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatPilotApp extends ConsumerWidget {
  ChatPilotApp({super.key, GoRouter? router})
      : _router = router ?? createAppRouter();

  final GoRouter _router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'ChatPilot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: _router,
    );
  }
}
