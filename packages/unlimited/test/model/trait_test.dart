import 'dart:io' as io;

import 'package:jsonut/jsonut.dart';
import 'package:path/path.dart' as p;
import 'package:scrap/scrap.dart' as scrap;
import 'package:unlimited/core.dart';

import '../test_lib.dart';

void main() {
  late final Set<String> traits;

  setUpAll(() {
    // TODO: Replace this with something that doesn't break 'dart test'.
    final projectRoot = io.Platform.script.resolve('../../../..').toFilePath();
    final jsonObject = JsonObject.parse(
      io.File(
        p.join(
          projectRoot,
          'data',
          'sor.json',
        ),
      ).readAsStringSync(),
    );
    final sparkOfRebellion = scrap.Expansion.fromJson(jsonObject);
    final traitsBuilder = <String>{};
    for (final card in sparkOfRebellion.cards) {
      traitsBuilder.addAll(
        switch (card) {
          final scrap.UnitCard c => c.traits,
          final scrap.LeaderCard c => c.traits,
          final scrap.UpgradeCard c => c.traits,
          final scrap.EventCard c => c.traits,
          _ => const [],
        },
      );
    }
    traits = Set.unmodifiable(traitsBuilder.toList()..sort());
  });

  test('all traits are present in Trait.values in ABC order', () {
    check(Trait.values.length).equals(traits.length);
    check(Trait.values.map((t) => t.name)).containsInOrder(traits);
  });
}
