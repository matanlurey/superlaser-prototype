/// Deck construction.
///
/// This library provides classes for constructing and validating decks.
///
/// ## Usage
///
/// ```dart
/// import 'package:unlimited/build.dart';
/// ```
///
/// ## Scope
///
/// This library provides static type checking and some low-level correctness
/// checks. For example, the [LimitedDeck] class ensures that the deck has no
/// more than 3 copies of any card:
///
/// ```dart
/// import 'package:unlimited/catalog/sor.dart' as sor;
///
/// // Throws an error.
/// final deck = LimitedDeck(
///   base: sor.administratorsTower,
///   leader: sor.directorKrennic,
///   cards: [
///     // Intentionally include 30 copies of the same card, which is invalid.
///     for (var i = 0; i < 30; i++) sor.deathTrooper,
///   ],
/// );
/// ```
///
/// However, these checks are intended to make the classes easy to reason about,
/// not to be user facing or part of a user interface. For example, programs
/// that take input to build a [LimitedDeck] should check constraints (such as
/// no more than 3 copies) before creating the deck (and not rely on the library
/// to throw an error).
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
