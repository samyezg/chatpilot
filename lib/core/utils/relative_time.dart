import 'package:chatpilot_app/l10n/app_localizations.dart';

String formatRelativeTime(
  DateTime value, {
  required AppLocalizations l10n,
  DateTime? now,
}) {
  final current = now ?? DateTime.now();
  final local = value.toLocal();
  final diff = current.difference(local);

  if (diff.inMinutes < 1) return l10n.justNow;
  if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
  if (diff.inDays == 1) return l10n.yesterday;
  if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}
