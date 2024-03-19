import 'package:unlimited/core.dart';

import '../test.dart';

void main() {
  group('$Aspect', () {
    test('toString() based on `name`', () {
      check('${Aspect.vigilance}').endsWith('<Vigilance>');
      check('${Aspect.command}').endsWith('<Command>');
      check('${Aspect.aggression}').endsWith('<Aggression>');
      check('${Aspect.cunning}').endsWith('<Cunning>');
      check('${Aspect.heroism}').endsWith('<Heroism>');
      check('${Aspect.villainy}').endsWith('<Villainy>');
    });

    test('each color is different', () {
      check(Aspect.values.map((v) => v.color).toSet())
          .length
          .equals(Aspect.values.length);
    });

    test('has 2 morale and 4 neutral aspects', () {
      check(Aspect.neutral)
        ..unorderedEquals([
          Aspect.vigilance,
          Aspect.command,
          Aspect.aggression,
          Aspect.cunning,
        ])
        ..every((p) => p.has((h) => h.isNeutral, 'isNeutral').isTrue());

      check(Aspect.morale)
        ..unorderedEquals([
          Aspect.heroism,
          Aspect.villainy,
        ])
        ..every((p) => p.has((h) => h.isMorale, 'isMorale').isTrue());
    });
  });
}
