import 'package:unlimited/catalog.dart';

import 'test_lib.dart';

void main() {
  test('catalog can initialize', () {
    check(
      catalog.lookup(CardReference(expansion: 'sor', number: 1)),
    ).isNotNull();
  });
}
