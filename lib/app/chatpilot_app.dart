import 'package:chatpilot_app/app/router/app_router.dart';
import 'package:chatpilot_app/app/theme/app_theme.dart';
import 'package:chatpilot_app/features/settings/presentation/settings_notifier.dart';
import 'package:chatpilot_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatPilotApp extends ConsumerWidget {
  ChatPilotApp({super.key, GoRouter? router})
      : _router = router ?? createAppRouter();

  final GoRouter _router;

  static const _supported = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'ChatPilot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: _router,
      locale: settings.materialLocale,
      supportedLocales: _supported,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeResolutionCallback: (locale, supported) {
        if (locale == null) return const Locale('en');
        for (final item in supported) {
          if (item.languageCode == locale.languageCode) return item;
        }
        // zh-CN / zh-TW → zh
        if (locale.languageCode.toLowerCase().startsWith('zh')) {
          return const Locale('zh');
        }
        return const Locale('en');
      },
    );
  }
}
