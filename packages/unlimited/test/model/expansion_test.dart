import 'package:unlimited/core.dart';

import '../test_lib.dart';

void main() {
  group('$Expansion', () {
    test('equivalent based on `code`', () {
      final a = _expansion('a', 1);
      final b = _expansion('a', 1);
      final c = _expansion('c', 2);

      check(a, because: 'a.code == b.code').equivalent(b);
      check(a, because: 'a.code != b.code').not((v) => v.equivalent(c));
    });

    test('toString() based on `code`', () {
      final a = _expansion('a', 1);
      final b = _expansion('b', 1);

      check('$a', because: 'a.code').toString().contains('<a>');
      check('$b', because: 'b.code').toString().contains('<b>');
    });

    test('formatCard returns formatted string', () {
      final a = _expansion('a', 100);
      final b = _expansion('b', 1000);

      check(a.formatCard(1), because: 'a.count').equals('A 001/100');
      check(b.formatCard(1), because: 'b.count').equals('B 0001/1000');
    });
  });
}

Expansion _expansion(String code, int count) {
  return UnreleasedExpansion(
    name: code,
    code: code,
    count: count,
    releaseEstimate: DateTime.utc(2025),
  );
}
