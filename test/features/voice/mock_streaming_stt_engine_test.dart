import 'package:chatpilot_app/features/voice/data/mock_streaming_stt_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mock engine streams growing prefixes then final', () async {
    final engine = MockStreamingSttEngine(
      phrase: '你好',
      charDelay: const Duration(milliseconds: 1),
    );

    final updates = await engine.start().toList();
    expect(updates.first.isFinal, isFalse);
    expect(updates.last.text, '你好');
    expect(updates.last.isFinal, isTrue);
  });

  test('cancel stops without requiring final', () async {
    final engine = MockStreamingSttEngine(
      phrase: '很长的一句演示文本用来打断',
      charDelay: const Duration(milliseconds: 30),
    );

    final collected = <String>[];
    final sub = engine.start().listen((u) => collected.add(u.text));
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await engine.cancel();
    await sub.asFuture<void>().timeout(
          const Duration(milliseconds: 200),
          onTimeout: () {},
        );
    expect(collected, isNotEmpty);
    expect(collected.last, isNot(equals('很长的一句演示文本用来打断')));
  });
}
