import 'package:unlimited/src/model/expansion.dart';

import '../test.dart';

void main() {
  group('$Expansion', () {
    test('equivalent based on `code`', () {
      final a = Expansion(name: 'a', code: 'a');
      final b = Expansion(name: 'b', code: 'a');
      final c = Expansion(name: 'c', code: 'c');

      check(a, because: 'a.code == b.code').equivalent(b);
      check(a, because: 'a.code != b.code').not((v) => v.equivalent(c));
    });

    test('toString() based on `code`', () {
      final a = Expansion(name: 'a', code: 'a');
      final b = Expansion(name: 'b', code: 'b');

      check('$a', because: 'a.code').toString().contains('<a>');
      check('$b', because: 'b.code').toString().contains('<b>');
    });
  });
}
