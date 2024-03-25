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

  test('dispenses on a typical distribution', () {
    // Similar to LeaderCard.
    final dispsenser = Dispenser(
      [
        (0.1640, () => 'RL'),
        (0.1300, () => 'CHL'),
        (0.0300, () => 'RHL'),
        (0.0038, () => 'SL'),
      ],
      orElse: () => 'CL',
    );

    // Generate 1000 leaders equally distributed from 0.0 to 1.0.
    final leaders = [
      for (var i = 0; i < 1000; i++) dispsenser.dispense(i / 1000),
    ];

    // Check the distribution of the leaders are within expected ranges.
    check(leaders.where((leader) => leader == 'RL')).which(
      (l) => l.length.equals(164),
    );
    check(leaders.where((leader) => leader == 'CHL')).which(
      (l) => l.length.equals(131),
    );
    check(leaders.where((leader) => leader == 'RHL')).which(
      (l) => l.length.equals(30),
    );
    check(leaders.where((leader) => leader == 'SL')).which(
      (l) => l.length.equals(3),
    );
    check(leaders.where((leader) => leader == 'CL')).which(
      (l) => l.length.equals(672),
    );
  });
}
