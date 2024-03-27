/// Deck construction.
///
/// This library provides classes for constructing and validating decks.
///
/// ## Example
///
/// Generating and building a (terrible) [LimitedDeck] for sealed play:
///
/// ```dart
/// import 'package:unlimited/build.dart';
/// import 'package:unlimited/catalog/sor.dart' as sor;
///
/// void main() {
///   // Generate 6 packs.
///   final generator = BoosterGenerator.of(sor.cards);
///   final packs = [
///     for (var i = 0; i < 6; i++) generator.create(),
///   ];
///
///   // Just pick the first base and leader, and 30 more cards.
///   final deck = LimitedDeck(
///     base: packs.first.base,
///     leader: packs.first.leader,
///     cards: packs.expand((pack) => pack.others).take(30),
///   );
///
///   // ...
/// }
/// ```
library build;

import 'package:unlimited/src/build/deck.dart';

export 'src/build/booster.dart' show BoosterGenerator, BoosterPack;
export 'src/build/deck.dart' show Deck, LimitedDeck, PremierDeck, TwinSunsDeck;
