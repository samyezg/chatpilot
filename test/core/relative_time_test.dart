import 'package:chatpilot_app/core/utils/relative_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats recent times', () {
    final now = DateTime(2026, 11, 10, 12);
    expect(
      formatRelativeTime(now.subtract(const Duration(minutes: 3)), now: now),
      '3m ago',
    );
    expect(
      formatRelativeTime(now.subtract(const Duration(hours: 2)), now: now),
      '2h ago',
    );
  });
}
