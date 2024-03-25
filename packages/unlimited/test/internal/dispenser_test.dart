import 'package:unlimited/src/internal.dart';

import '../test_lib.dart';

void main() {
  test('dispenses on a distribution', () {
    final dispenser = Dispenser([
      (0.5, () => 'A'),
      (0.3, () => 'B'),
      (0.2, () => 'C'),
    ]);

    expect(dispenser.dispense(0.0), 'A');
    expect(dispenser.dispense(0.5), 'B');
    expect(dispenser.dispense(0.8), 'C');
  });

  test('dispenses on a distribution with a fallback', () {
    final dispenser = Dispenser(
      [
        (0.5, () => 'A'),
        (0.3, () => 'B'),
        (0.1, () => 'C'),
      ],
      orElse: () => 'D',
    );

    expect(dispenser.dispense(0.9), 'D');
  });
}
