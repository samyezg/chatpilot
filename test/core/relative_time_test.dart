import 'package:chatpilot_app/core/utils/relative_time.dart';
import 'package:chatpilot_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('formats recent times in en and zh', (tester) async {
    late AppLocalizations en;
    late AppLocalizations zh;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) {
            en = AppLocalizations.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('zh'),
        home: Builder(
          builder: (context) {
            zh = AppLocalizations.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final now = DateTime(2026, 11, 10, 12);
    expect(
      formatRelativeTime(
        now.subtract(const Duration(minutes: 3)),
        l10n: en,
        now: now,
      ),
      '3m ago',
    );
    expect(
      formatRelativeTime(
        now.subtract(const Duration(hours: 2)),
        l10n: en,
        now: now,
      ),
      '2h ago',
    );
    expect(
      formatRelativeTime(
        now.subtract(const Duration(minutes: 3)),
        l10n: zh,
        now: now,
      ),
      '3 分钟前',
    );
    expect(
      formatRelativeTime(
        now.subtract(const Duration(hours: 2)),
        l10n: zh,
        now: now,
      ),
      '2 小时前',
    );
  });
}
