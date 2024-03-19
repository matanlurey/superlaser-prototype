import 'package:unlimited/src/model/expansion.dart';

import '../test.dart';

void main() {
  group('$Expansion', () {
    test('equivalent based on `code`', () {
      final a = Expansion(name: 'a', code: 'a', count: 1);
      final b = Expansion(name: 'b', code: 'a', count: 1);
      final c = Expansion(name: 'c', code: 'c', count: 1);

      check(a, because: 'a.code == b.code').equivalent(b);
      check(a, because: 'a.code != b.code').not((v) => v.equivalent(c));
    });

    test('toString() based on `code`', () {
      final a = Expansion(name: 'a', code: 'a', count: 1);
      final b = Expansion(name: 'b', code: 'b', count: 1);

      check('$a', because: 'a.code').toString().contains('<a>');
      check('$b', because: 'b.code').toString().contains('<b>');
    });

    test('formatCard returns formatted string', () {
      final a = Expansion(name: 'a', code: 'a', count: 100);
      final b = Expansion(name: 'b', code: 'b', count: 1000);

      check(a.formatCard(1), because: 'a.count').equals('A 001/100');
      check(b.formatCard(1), because: 'b.count').equals('B 0001/1000');
    });
  });
}
